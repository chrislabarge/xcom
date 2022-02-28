module Xcommy
  class Display
    attr_accessor :user_interface
    attr_reader :game

    # What is this class really responsible for?
    def initialize(game)
      @game = game
      @user_interface = UserInterface.new(@game)
      @screen = Screen.new(@game)
      @cinematic_scene = CinematicScene.new(@game, @screen)
    end

    def render(turn_option)
      if CinematicScene.types.include?(turn_option.to_sym)
        @cinematic_scene.render(turn_option)

        @game.take_turn!(turn_option)

        if @game.over?
          @screen.render(:game_over)
        else
          @screen.render(:turn)
        end
      else
        @screen.render(turn_option)
      end
    end

    def current_screen
      @screen.current
    end

    def current_selection
      if current_screen == :move
        @user_interface.refresh_alert_message!
        @screen.spot_screen
      else
        option = @user_interface.menu.current_selection

        unless CinematicScene.types.include?(option)
          @game.board.show_cursor!
          @user_interface.menu.cursor.move_to_top!
        end

        option
      end
    end

    def change_cursor_position(direction)
      if current_screen == :move
        @game.board.cursor.move_in direction
      else
        @user_interface.menu.cursor.move_in direction
      end

      if current_screen == :fire
        @game.board.toggle_static_cursor
      end
    end
  end
end
