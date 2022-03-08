require 'io/console'

module Xcommy
  class Game
    attr_accessor :cover,
                  :npcs,
                  :players,
                  :current_player,
                  :current_screen,
                  :fired_shot,
                  :hit_damage,
                  :board,
                  :user_interface

    def initialize
      @cover = []
      @npcs = []
      @players = []
      @board = Board.new self
      @user_interface = UserInterface.new self
      @fired_shot = nil
      @hit_damage = 10
    end

    def networking?
      @network != nil
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

    def start
      @board.refresh!
      @current_player = @players.first
      render(:turn)

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

    def render(screen_type)
      if CinematicScene.types.include?(screen_type.to_sym)
        CinematicScene.new(self).render(screen_type)
        take_turn!

        screen_type = over? ? :game_over : :turn
      end

      Screen.new(self).render(screen_type)
    end

    def over?
      !players.all?(&:alive?)
    end

    def current_selection
      if @current_screen == :move
        spot_screen
      else
        option = @user_interface.menu.current_selection

        unless CinematicScene.types.include?(option)
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

    def next_player
      players[-(players.index(@current_player) + 1)]
    end

    def take_turn!
      @current_player.turns_left -= 1

      if @current_player.turns_left.zero?
        @current_player = next_player
        @current_player.reset_turns_left!
      end
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
