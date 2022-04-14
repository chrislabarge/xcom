module Xcommy
  class Screen
    def initialize(game)
      @game = game
      @board = @game.board
    end

    def render(screen_type)
      set_current_screen_type screen_type

      puts content
    end

    def self.for_turn?(screen_type)
      ![:game_over, :start_menu, :network_url, :network_waiting].include? screen_type
    end

    def self.for_active_session?(screen_type)
      ![:start_menu, :network_url, :network_waiting].include? screen_type
    end

    def self.for_waiting_to_start?(screen_type)
      [:network_url, :network_waiting].include? screen_type
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

      if type == :cancel
        if Screen.for_active_session? @game.current_screen
          type = :new_turn
        else
          type = :start_menu
        end
      end

      @game.current_screen = type
    end

    def boarder_horizontal
      Array.new(85, "=").join
    end

    def blank_line
      print ""
    end

    def merge_components
      board_rows = @board.render
      user_interface_rows = @game.user_interface.content_rows
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
