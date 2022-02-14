module Xcommy
  class UserInterface
    attr_accessor :cursor_index, :alert_message, :current_screen, :game

    def initialize(game)
      @game = game
      @cursor_index = 0
      @menu = Menu.new(self)
      refresh_alert_message!
    end

    def render(current_screen)
      @content = []
      @current_screen = current_screen
      build!
      @content
    end

    def current_cursor_menu_option_board_object
      # This will need to be dynamically dirived
      @game.enemies[0]
    end

    def refresh_alert_message!
      @alert_message = nil
    end

    def cursor_selected_menu_option
      @menu.options[@cursor_index].gsub(/\s+/, "_").downcase.to_sym
    end

    def update_cursor_index(direction)
      if direction == :down
        if @cursor_index == 0
          @cursor_index = @menu.options.count - 1
        else
          @cursor_index -= 1
        end
      else
        if @cursor_index == @menu.options.count - 1
          @cursor_index = 0
        else
          @cursor_index += 1
        end
      end
    end

    def build!
      @content << interface_top_border

      @content << interface_line
      @content << interface_text_line("Player 1")
      @content << interface_line
      @content << interface_divider

      @content << interface_text_line("Health")
      @content << interface_text_line("100")
      @content << interface_divider

      @content << interface_text_line(screen_title)

      @content << interface_text_line("Turn")
      @content << interface_text_line(turn_display)

      @menu.options.each do |option|
        @content << interface_divider
        @content << interface_text_line(option, cursor: @menu.options[@cursor_index] == option)
      end

      unless @alert_message.nil?
        @content << interface_text_line(@alert_message)
      end

      @content << interface_divider

      number_of_empty_interface_lines.times do
        @content << interface_line
      end

      @content << interface_bottom_border
    end

    def screen_title
      case @current_screen
      when :turn
        "Choose Action"
      when :move_to
        "Moving..."
      when :move
        "Selecting..."
      when :spot
        "Spot Selected"
      when :fire
        "Select Enemy"
      when :enemy_1
        "Firing..."
      when :hit
        "Hit!"
      when :miss
        "Miss!"
      end
    end

    def number_of_empty_interface_lines
      count = (8 - (@menu.options.count * 2))
      count -= 1 unless @alert_message.nil?
      count
    end

    def turn_display
      prefix =
        if @game.turns_left == 2
          1
        elsif @game.turns_left == 1
          2
        else
          0
        end
      "(#{prefix} of 2)"
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

    def even_adjustment(text)
      if text.length > 6
        " " << text
      else
        text << " "
      end
    end
  end
end
