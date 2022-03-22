require 'io/console'

module Xcommy
  class Game
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

    def initialize
      @cover = []
      @npcs = []
      @players = []
      @board = Board.new self
      @user_interface = UserInterface.new self
      @fired_shot = nil
      @hit_damage = 10
    end

    def server_url
      @server.url
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
      @cover = Setup.generate_cover(self)
      @players[0].respawn!([9, 0])
      @players[1].respawn!([0, 0])
      @board.refresh!
      @current_player = @players.first
    end

    def start_server!
      @server = Server.new
      Process.fork do
        @server.run
      end
    end

    def start
      @board.refresh!
      @current_player = @players.first

      render(:new_turn)

      unless Setup.testing?
        loop do
          render accept_input
        end
      end
    end

    def mock_input(input)
      render accept_input(input)
    end

    private

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

    def render(screen_type)
      if Turn.types.include?(screen_type.to_sym)
        generate_turn!(screen_type)
        screen_type = after_turn_screen_type
      end

      Screen.new(self).render(screen_type)

      if screen_type == :waiting
        next_turn = Turn.find(next_turn_id, self)

        # This is just for testing purposes right now
        # allows testing current state of the test game
        return if next_turn == nil && ENV["TESTING"] == "true"

        while next_turn == nil
          next_turn = Turn.find(next_turn_id, server_url)
          # this sleep prevents requesting turn from server to often
          sleep(2)
        end

        save_turn! next_turn

        unless local_players.include?(@current_player)
          render(:waiting)
        end
      end
    end

    def over?
      !players.all?(&:alive?)
    end

    def current_selection
      if @current_screen == :move
        spot_screen
      else
        option = @user_interface.menu.current_selection

        unless Turn.types.include?(option)
          @board.show_cursor!
          @user_interface.menu.cursor.move_to_top!
        end

        option
      end
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

    def generate_turn!(screen_type)
      turn = Turn.new(game: self)

      case screen_type.to_sym
      when :move_to
        turn.type = :move_to
      else
        @fired_shot = new_fired_shot
        turn.type = @fired_shot.result
        turn.player_index = other_players.last.index
      end

      if turn.successful?
        save_turn! turn
      end
    end

    def save_turn!(turn)
      CinematicScene.render(turn)
      @last_turn = turn

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

    # what accepting a current screen allows for is to keep track of state
    # I think what I should be doing instead is the opposite. Just re-render
    # by default and "refresh" what input is selected/entered by the user
    def accept_input(input = STDIN.getch)
      next_screen = nil
      case input
      when "j"
        change_cursor_position(:down)
      when "k"
        change_cursor_position(:up)
      when "h"
        change_cursor_position(:left)
      when "l"
        change_cursor_position(:right)
      when "\r"
        @user_interface.menu.select_highlighted_item!
        if @user_interface.menu.exit_currently_selected?
          exit
        else
          next_screen = current_selection.downcase.to_sym
        end
      when "c"
        exit
      end
      next_screen || @current_screen
    end

    def change_cursor_position(direction)
      if @current_screen == :move
        @board.cursor.move_in direction
      else
        @user_interface.menu.cursor.move_in direction
      end

      if @current_screen == :fire
        @board.toggle_static_cursor
      end
    end
  end
end
