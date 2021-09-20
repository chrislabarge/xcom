module Xcommy
  class Display
    attr_reader :content
    attr_reader :game

    def initialize(game)
      @content = []
      @game = game
      @cursor_index = 0
      @cursor_coords = nil
      @current_screen = nil
    end

    def current_option
      player_options[@cursor_index]
    end

    def refresh
      @cursor_index = 0
      @cursor_coords = [0, 0] #@game.current_player.postion
    end

    def turn
      screen(:turn)
    end

    def move
      screen(:move)
    end

    def screen(type)
      @current_screen = type
      5.times do
        content << blank_line
      end
      content << boarder_horizontal
      content << merge_components(new_playing_board(type), user_interface(type))
      content << blank_line
      content << boarder_horizontal
      content << blank_line
      content
    end

    def update_cursor_index(direction)
      if direction == :down
        if @cursor_index == 0
          @cursor_index = player_options.count - 1
        else
          @cursor_index -= 1
        end
      else
        if @cursor_index == player_options.count - 1
          @cursor_index = 0
        else
          @cursor_index += 1
        end
      end
    end

    def update_cursor_coords(direction)
      case direction
      when :up
        @cursor_coords[0] -= 1
      when :down
        @cursor_coords[0] += 1
      when :left
        @cursor_coords[1] -= 1
      when :right
        @cursor_coords[1] += 1
      end

      exit
    end

    def change_cursor_position(direction)
      if @current_screen == :turn
        update_cursor_index direction
      else
        update_cursor_coords direction
      end
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

    def new_playing_board(type)
      board = []
      board << Array.new(10, "_____").join + "_"
      10.times do
        board << Array.new(10, "|    ").join + "|"
        board << Array.new(10, "|____").join + "|"
      end
      board
    end

    def user_interface(type)
      interface = []
      interface << interface_top_border
      interface << interface_line
      interface << interface_text_line("Player 1")
      interface << interface_line
      interface << interface_divider
      interface << interface_text_line("Health")
      interface << interface_text_line("100")
      interface << interface_divider
      interface << interface_text_line(screen_title(type))
      interface << interface_text_line("(1 of 2)")

      player_options.each do |option|
        interface << interface_divider
        interface << interface_text_line(option, cursor: player_options[@cursor_index] == option)
      end

      interface << interface_divider
      5.times do
        interface << interface_line
      end
      interface << interface_bottom_border
    end

    def screen_title(type)
      case type.to_sym
      when :turn
        "Take Turn"
      when :move
        "Make Move"
      when :fire
        "Select"
      end
    end

    def player_options
      ["Move", "Fire"]
    end

    def interface_top_border
      Array.new(28, "_").join
    end

    def interface_bottom_border
      "_|" + Array.new(22, "_").join + "|__|"
    end

    def interface_divider
      " |" + Array.new(22, "-").join + "|  |"
    end

    def interface_line
      " |" + Array.new(22, " ").join + "|  |"
    end

    def interface_text_line(text, cursor: false)
      if !text.length.even?
        text = even_adjustment(text)
      end

      length = (22 - text.length) / 2

      cursor_section =
        if cursor == true
          Array.new(length - 3, " ").join + ">> "
        else
          Array.new(length, " ").join
        end

      " |" +
        cursor_section +
        text +
        Array.new(length, " ").join +
        "|  |"
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
