module Xcommy
  module Utilities
    def generate_cover
      coords = []

      coords << [8, 3]
      coords << [1, 3]

      coords.map do |coord|
        Cover.new(self, coord, :full_wall)
      end
    end

    def mock_input(input)
      render accept_input(input)
    end

    # what accepting a current screen allows for is to keep track of state
    # I think what I should be doing instead is the opposite. Just re-render
    # by default and "refresh" what input is selected/entered by the user
    def accept_input(input = $stdin.getch)
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
          stop!
        else
          next_screen = current_selection.downcase.to_sym
        end
      when "c"
        stop!
      end
      next_screen || @current_screen
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
          next_turn = Turn.find(next_turn_id, self)
          # this sleep prevents requesting turn from server to often
          sleep(2)
        end

        save_turn! next_turn

        if @current_player.from_local_client?
          render(:new_turn)
        else
          render(:waiting)
        end
      end
    end

    def current_selection
      if @current_screen == :move
        spot_screen
      else
        option = @user_interface.menu.current_selection

        if Screen.for_active_session?(@current_screen) && !Turn.types.include?(option)
          # Why is this here??
          @board.show_cursor!
          @user_interface.menu.cursor.move_to_top!
        end

        option
      end
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
