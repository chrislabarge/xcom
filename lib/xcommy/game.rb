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

    def next_turn_id
      (@last_turn&.id || 0) + 1
    end

    # TODO - Decide on the best boolean for determining if game is in
    # network mode
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

    def setup_and_start!
      start starting_screen
    end

    def over?
      !players.all?(&:alive?)
    end

    private

    def starting_screen
      @server_url.nil? ? screen_for_selected_game_type : :waiting
    end

    def screen_for_selected_game_type
      # Hack for now
      return :start_menu if Setup.testing?

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
        poll_for_connected_players!
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
        return turn
      end

      nil
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
