module Xcommy
  class Display
    attr_accessor :user_interface
    attr_reader :game

    def initialize(game)
      @game = game
      @user_interface = UserInterface.new(@game)
      @screen = Screen.new(@game, @user_interface)
      @cinematic_scene = CinematicScene.new(@game, @screen)
    end

    def render(turn_option)
      if CinematicScene.types.include?(turn_option.to_sym)
        @cinematic_scene.send(turn_option)
        @game.current_turns << turn_option
        #this render turn should be dependent on how many turns left
        #and extracted out of this function probably.
        @screen.render(:turn)
      else
        @screen.render(turn_option)
      end
    end

    def current_screen
      @screen.current
    end

    def current_selection
      case current_screen
      when :move
        @user_interface.refresh_alert_message!
        @screen.spot_screen
      else option = @user_interface.cursor_selected_menu_option
        unless CinematicScene.types.include?(option)
          # have this user interface stuff start up coming from the class itself
          @user_interface.cursor_index = 0
          @game.board.cursor.set_on(
            @user_interface.current_cursor_menu_option_board_object.current_position
          )
          @game.board.refresh!
        end
        option
      end
    end

    def change_cursor_position(direction)
      case current_screen
      when :move
        @game.board.cursor.move_in direction
      when :fire
        @user_interface.update_cursor_index direction

          if @user_interface.cursor_selected_menu_option == :cancel
            @game.board.cursor.hide!
          else
            @game.board.cursor.set_on(
              @user_interface.current_cursor_menu_option_board_object.current_position
            )
            @game.board.refresh!
          end
      else
        @user_interface.update_cursor_index direction
      end
    end
  end
end
