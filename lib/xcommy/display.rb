module Xcommy
  class Display
    attr_reader :content
    attr_reader :game

    def initialize(game)
      @content = []
      @game = game
    end

    # This was just to sync action name to clean up code
    def turn
      content << blank_line
      content << boarder_horizontal
      content << merge_components(new_playing_board, user_interface)
      content << blank_line
      content << boarder_horizontal
      content << blank_line
      content
    end

    def blank_line
      print ""
    end

    def merge_components(new_playing_board, user_interface)
      merger = []

      new_playing_board.each_with_index do |display_line, index|
        connector =
          if index == 0 || index == (new_playing_board.count - 1)
            "_"
          else
            " "
          end

        merger[index] = "   " + display_line + connector + user_interface[index]
      end

      merger
    end

    def new_playing_board
      board = []
      board << Array.new(10, "_____").join + "_"
      10.times do
        board << Array.new(10, "|    ").join + "|"
        board << Array.new(10, "|____").join + "|"
      end
      board
    end

    def user_interface
      interface = []
      interface << interface_top_border
      interface << interface_line
      interface << interface_text_line("Player 1")
      interface << interface_line
      interface << interface_divider
      interface << interface_text_line("Health")
      interface << interface_text_line("100")
      interface << interface_divider
      interface << interface_text_line("Take Turn")
      interface << interface_text_line("(1 of 2)")
      interface << interface_divider
      interface << interface_text_line("Move")
      interface << interface_divider
      interface << interface_text_line("Fire")
      interface << interface_divider
      5.times do
        interface << interface_line
      end
      interface << interface_bottom_border
    end

    def interface_top_border
      Array.new(26, "_").join
    end

    def interface_bottom_border
      "_|" + Array.new(22, "_").join + "|_"
    end

    def interface_divider
      " |" + Array.new(22, "-").join + "| "
    end

    def interface_line
      " |" + Array.new(22, " ").join + "| "
    end

    def interface_text_line(text)
      if !text.length.even?
        text = even_adjustment(text)
      end

      length = (22 - text.length) / 2
      " |" +
        Array.new(length, " ").join +
        text +
        Array.new(length, " ").join +
        "| "
    end

    def even_adjustment(text)
      if text.length > 6
        " " << text
      else
        text << " "
      end
    end

    def boarder_horizontal
      Array.new(85, "=").join
    end
  end
end
