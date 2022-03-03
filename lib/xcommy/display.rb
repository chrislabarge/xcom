module Xcommy
  class Display
    attr_reader :game

    # What is this class really responsible for?
    def initialize(game)
      @game = game
    end

    def render(turn_option)
      if CinematicScene.types.include?(turn_option.to_sym)
        CinematicScene.new(@game).render(turn_option)
        @game.take_turn!(turn_option)

        screen_type = @game.over? ? :game_over : :turn
        Screen.new(@game).render(screen_type)
      else
        Screen.new(@game).render(turn_option)
      end
    end

    def current_selection
      if @game.current_screen == :move
        spot_screen
      else
        option = @game.user_interface.menu.current_selection

        unless CinematicScene.types.include?(option)
          @game.board.show_cursor!
          @game.user_interface.menu.cursor.move_to_top!
        end

        option
      end
    end

    def change_cursor_position(direction)
      if @game.current_screen == :move
        @game.board.cursor.move_in direction
      else
        @game.user_interface.menu.cursor.move_in direction
      end

      if @game.current_screen == :fire
        @game.board.toggle_static_cursor
      end
    end

    private

    def spot_screen
      @game.user_interface.refresh_alert_message!

      if @game.board.cursor_spot.nil?
        :spot
      else
        @game.user_interface.alert_message = "Spot not available"
        :move
      end
    end
  end
end
