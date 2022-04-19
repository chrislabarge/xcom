require 'io/console'
require "http"

module Xcommy
  class Game
    include Utilities

    attr_accessor :cover,
                  :npcs,
                  :players,
                  :current_player,
                  :current_screen,
                  :last_turn,
                  :fired_shot,
                  :hit_damage,
                  :board,
                  :user_interface,
                  :server

    def initialize(server_url: nil)
      @cover = []
      @npcs = []
      @players = []
      @board = Board.new self
      @board.refresh!
      @user_interface = UserInterface.new self
      @fired_shot = nil
      @server_url = server_url
      @hit_damage = 30
    end

    def server_url
      @server_url || @server&.url
    end

    def next_turn_id
      (@last_turn&.id || 0) + 1
    end

    def networking?
      @players.any?(&:from_network_client?)
    end

    def other_players
      players - [current_player]
    end

    def restart!
      @npcs = []
      @cover = generate_cover
      @players[0].respawn!([9, 0])
      @players[1].respawn!([0, 0])
      @board.refresh!
      @current_player = @players.first
    end

    def start_server!
      @server = Server.new

      @server_pid = Process.fork do
        @server.run
      end
    end

    def stop!
      Process.kill("HUP", @server_pid) if @server

      exit
    end

    def base_url
      "http://#{server_url}"
    end

    def setup!
      start starting_screen
    end

    private

    def starting_screen
      @server_url.nil? ? screen_from_selected_game_type : :waiting
    end

    def screen_from_selected_game_type
      render(:start_menu)
      next_screen = nil

      loop do
        next_screen = accept_input

        if [:new_turn, :network_url].include? next_screen
          return next_screen
        else
          render next_screen
        end
      end
    end

    def start(screen_type)
      @players = [
        Player.new(self, [9, 0]),
        Player.new(self, [0, 0])
      ]
      @cover = generate_cover

      # this ||= is for testing purposes.
      @current_player ||= @players.first
      @board.refresh!

      case screen_type
      when :network_url
        start_server!
        @players.last.from_local_client = false
        start_polling!
      when :waiting
        @players.first.from_local_client = false
      end

      render screen_type

      unless Setup.testing?
        loop do
          render accept_input
        end
      end
    end

    def local_players
      @players.select(&:from_local_client?)
    end

    def after_turn_screen_type
      return :game_over if over?

      if local_players.include?(@current_player)
        :new_turn
      else
        :waiting
      end
    end

    def over?
      !players.all?(&:alive?)
    end

    def spot_screen
      @user_interface.refresh_alert_message!

      if @board.cursor_spot.nil?
        :spot
      else
        @user_interface.alert_message = "Spot not available"
        :move
      end
    end

    def start_polling!
      Thread.new do
        response = nil

        while !response&.status&.success? do
          response = HTTP.get("#{base_url}/start")
          sleep(2)
        end

        @user_interface.menu.cursor.move_to_top!

        render(:new_turn)
      end
    end

    def generate_turn!(screen_type)
      turn = Turn.new(game: self)

      case screen_type.to_sym
      when :move_to
        turn.type = :move_to
      else
        @fired_shot = new_fired_shot
        turn.type = @fired_shot.result
        turn.player_index = other_players.last.index
        if turn.type.to_sym == :hit
          turn.damage = @hit_damage
        end
      end

      if turn.successful?
        save_turn! turn
      end
    end

    def save_turn!(turn)
      CinematicScene.render(turn)
      @last_turn = turn

      if @last_turn.type.to_sym == :hit
        player = players[@last_turn.player_index]
        player.health -= @last_turn.damage
        player.health = 0 if player.health < 0
      end

      @current_player.turns_left -= 1

      if @current_player.turns_left.zero?
        @current_player = next_player
        @current_player.reset_turns_left!
      end
    end

    def new_fired_shot
      @current_player.fire_shot(at: other_players.last)
    end

    def next_player
      players[-(players.index(@current_player) + 1)]
    end
  end
end
