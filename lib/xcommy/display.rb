module Xcommy
  class Display
    attr_accessor :user_interface
    attr_reader :content, :current_screen
    attr_reader :game

    def initialize(game)
      @content = []
      @game = game
      @user_interface = UserInterface.new(@game)
      @screen = Screen.new(@game, @user_interface)
      @current_screen = nil
    end

    def render(turn_option)
      if CinematicScene.types.include?(turn_option.to_sym)
        CinematicScene.new(@game, self, @screen).send(turn_option)
        @game.current_turns << turn_option
        render(:turn)
      else
        screen_type = turn_option.to_sym
        screen_type = :turn if screen_type == :cancel
        # TODO - I think @current_screen is a misnomer as it is not set in the
        # conditional above
        @current_screen = screen_type
        show! @screen.render(screen_type)
      end
    end

    def current_selection
      case @current_screen
      when :move
        @user_interface.refresh_alert_message!
        @screen.spot_screen
      else option = @user_interface.cursor_selected_menu_option
        unless CinematicScene.types.include?(option)
          @user_interface.cursor_index = 0
          @game.board.show_spot_cursor!
        end
        option
      end
    end

    # This "SHOW" method should be extracted to a module that is included
    # in the CinematicScene + Screen classes that is then called in `#render`
    def show!(content)
      puts content
    end

    def change_cursor_position(direction)
      case @game.display.current_screen
      when :move
        @game.board.update_cursor_coords direction
      when :fire
        @user_interface.update_cursor_index direction
      else
        @user_interface.update_cursor_index direction
      end
    end

    def spot_cursor_visible?
      @current_screen == :move || @current_screen == :spot
    end
  end
end
