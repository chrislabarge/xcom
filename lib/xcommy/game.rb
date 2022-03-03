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
                  :display

    def initialize
      @cover = []
      @npcs = []
      @players = []
      @board = Board.new self
      @user_interface = UserInterface.new self
      @display = Display.new self
      @fired_shot = nil
      @hit_damage = 10
    end

    def other_players
      players - [current_player]
    end

    # See if makes sense to remove this
    def turns_left
      @current_player.turns_left
    end

    def render(screen)
      @display.render(screen)
    end

    def over?
      !players.all?(&:alive?)
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

    def take_turn!(turn)
      @current_player.current_turns << turn

      if turns_left == 0
        @current_player = next_player
        @current_player.reset_current_turns!
      end
    end

    # what accepting a current screen allows for is to keep track of state
    # I think what I should be doing instead is the opposite. Just re-render
    # by default and "refresh" what input is selected/entered by the user
    def accept_input(input = STDIN.getch)
      next_screen = nil
      case input
      when "j"
        @display.change_cursor_position(:down)
      when "k"
        @display.change_cursor_position(:up)
      when "h"
        @display.change_cursor_position(:left)
      when "l"
        @display.change_cursor_position(:right)
      when "\r"
        @user_interface.menu.select_highlighted_item!
        if @user_interface.menu.exit_currently_selected?
          exit
        else
          next_screen = @display.current_selection.downcase.to_sym
        end
      when "c"
        exit
      end
      next_screen || @current_screen
    end

    def mock_input(input)
      render accept_input(input)
    end

    private

    def next_player
      players[-(players.index(@current_player) + 1)]
    end
  end
end
