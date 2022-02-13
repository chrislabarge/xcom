module Xcommy
  # This board + User interface should all come from this call
  # The screen just glues them together
  # This model should really be called "screen builder" dependent on how I store state
  class Screen
    attr_accessor :current

    def initialize(game, user_interface)
      @game = game
      @user_interface = user_interface
    end

    def spot_screen
      if @game.board.cursor.spot.nil?
        :spot
      else
        @user_interface.alert_message = "Spot not available"
        :move
      end
    end

    def set_current(screen_type)
      type = screen_type.to_sym
      type = :turn if type == :cancel
      @current = type
    end

    def render(screen_type)
      set_current screen_type
      content = []

      5.times do
        content << blank_line
      end
      content << boarder_horizontal
      content << merge_components(
        @game.board.render,
        @user_interface.render(@current),
      )
      content << blank_line
      content << boarder_horizontal
      content << blank_line

      show! content
    end

    def merge_components(playing_board, user_interface)
      merger = []

      playing_board.each_with_index do |display_line, index|
        connector =
          if index == 0 || index == (playing_board.count - 1)
            "_"
          else
            " "
          end

        merger[index] = "   " + display_line + connector + user_interface[index]
      end

      merger
    end

    def blank_line
      print ""
    end

    def boarder_horizontal
      Array.new(85, "=").join
    end

    def show!(content)
      puts content
    end
  end
end
