module Xcommy
  class Display
    attr_reader :content
    attr_reader :game

    def initialize(game)
      @content = []
      @game = game
      @spot_width = 10
      @cursor_index = 0
      @cursor_coords = nil
      @current_screen = nil
      @board = {}
      @spot_width.times do |index|
        @board[index] = {}
      end
    end

    def current_selection
      if @current_screen == :move
        :spot
      else
        option = player_options[@cursor_index]
        refresh!
        option
      end
    end

    def spot
      screen(:spot)
    end

    def refresh!
      @cursor_index = 0
      @cursor_coords = [0, 0] #@game.current_player.postion
    end

    def turn
      screen(:turn)
    end

    def cancel
      screen(:turn)
    end

    def move
      screen(:move)
    end

    def screen(current)
      @content = []
      @current_screen = current
      5.times do
        content << blank_line
      end
      content << boarder_horizontal
      content << merge_components(playing_board, user_interface)
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
      @board[@cursor_coords[0]][@cursor_coords[1]] = nil
      case direction
      when :up
        @cursor_coords[0] -= 1 unless @cursor_coords[0] == 0
      when :down
        @cursor_coords[0] += 1 unless @cursor_coords[0] == (@spot_width - 1)
      when :left
        @cursor_coords[1] -= 1 unless @cursor_coords[1] == 0
      when :right
        @cursor_coords[1] += 1 unless @cursor_coords[1] == (@spot_width - 1)
      end
    end

    def change_cursor_position(direction)
      case @current_screen
      when :move
        update_cursor_coords direction
      else
        update_cursor_index direction
      end
    end

    def blank_line
      print ""
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

    def find_spot_type(spot_coords)
      return @board[spot_coords[0]][spot_coords[1]] unless spot_cursor_visible?
      if @cursor_coords[1] == spot_coords[1]
        if @cursor_coords[0] == spot_coords[0] + 1
          :top_cursor
        elsif @cursor_coords[0] == spot_coords[0] - 1
          :bottom_cursor
        end
      elsif @cursor_coords[0] == spot_coords[0]
        if @cursor_coords[1] == spot_coords[1] + 1
          :left_cursor
        elsif @cursor_coords[1] == spot_coords[1] - 1
          :right_cursor
        end
      end
    end

    def spot_cursor_visible?
      @current_screen == :move || @current_screen == :spot
    end

    def playing_board
      rows = []
      rows << Array.new(@spot_width, "_____").join + "_"
      @spot_width.times do |outer_index|
        top = []
        bottom = []

        @spot_width.times do |inner_index|
          spot_type = find_spot_type [outer_index, inner_index]
          top << Spot.for(:top, spot_type).to_s
          bottom << Spot.for(:bottom, spot_type).to_s
        end

        rows << top.join + "|"
        rows << bottom.join + "|"
      end
      rows
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
      interface << interface_text_line(screen_title)
      interface << interface_text_line("Turn")
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

    def screen_title
      case @current_screen
      when :turn
        "Choose Action"
      when :move
        "Select Spot"
      when :spot
        "Spot Selected"
      when :fire
        "Select"
      end
    end

    def player_options
      case @current_screen
      when :spot
        ["Move To", "Cancel"]
      else
        ["Move", "Fire"]
      end
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
