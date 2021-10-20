module Xcommy
  # This board + User interface should all come from this call
  # The screen just glues them together
  # This model should really be called "screen builder" dependent on how I store state
  class Screen
    def initialize(game, user_interface)
      @game = game
      @user_interface = user_interface
    end

    def self.cinematic
      [:move_to, :enemy_1, :hit, :miss]
    end

    def spot_screen
      if @game.board.cursor_spot.nil?
        :spot
      else
        @user_interface.alert_message = "Spot not available"
        :move
      end
    end

    def render(screen_type)
      content = []
      5.times do
        content << blank_line
      end
      content << boarder_horizontal
      content << merge_components(
        @game.board.render,
        @user_interface.render(screen_type),
      )
      content << blank_line
      content << boarder_horizontal
      content << blank_line
      content
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
  end
end
