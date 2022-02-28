module Xcommy
  class Screen
    attr_accessor :current

    def initialize(board, user_interface)
      @board = board
      @user_interface = user_interface
    end

    def render(screen_type)
      set_current_screen_type screen_type
      puts content
    end

    private

    def content
      screen_lines = []

      5.times do
        screen_lines << blank_line
      end

      screen_lines << boarder_horizontal
      screen_lines << merge_components
      screen_lines << blank_line
      screen_lines << boarder_horizontal
      screen_lines << blank_line
      screen_lines
    end

    def set_current_screen_type(screen_type)
      type = screen_type.to_sym
      type = :turn if type == :cancel
      @current = type
    end

    def boarder_horizontal
      Array.new(85, "=").join
    end

    def blank_line
      print ""
    end

    def merge_components
      board_rows = @board.render
      user_interface_rows = @user_interface.for_screen_type(@current)
      merger = []

      board_rows.each_with_index do |board_display_line, index|
        connector =
          if index == 0 || index == (board_rows.count - 1)
            "_"
          else
            " "
          end

        merger[index] = "   " + board_display_line + connector + user_interface_rows[index]
      end

      merger
    end
  end
end
