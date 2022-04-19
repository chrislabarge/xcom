module Xcommy
  class UserInterface
    attr_accessor :alert_message, :game, :menu

    def initialize(game)
      @game = game
      @menu = Menu.new(@game)
      refresh_alert_message!
    end

    def current_player
      @game.current_player
    end

    def content_rows
      build!
    end

    def refresh_alert_message!
      @alert_message = nil
    end

    private

    def build!
      content = []
      content << interface_top_border

      if Screen.for_active_session? @game.current_screen
        content << interface_line
        content << interface_text_line(current_player.label)
      else
        content << interface_line
        content << interface_text_line("Welcome!")
      end

      if @game.current_screen == :game_over
        content << interface_text_line("WINS!!!")
      else
        content << interface_line
      end

      content << interface_divider


      if Screen.for_active_session? @game.current_screen
        content << interface_text_line("Health")
        content << interface_text_line(current_player.health.to_s)
      else
        content << interface_text_line("Start Screen")
        content << interface_line
      end

      content << interface_divider

      content << interface_text_line(screen_title)

      if Screen.for_turn? @game.current_screen
        content << interface_text_line("Turn")
        content << interface_text_line(turn_display)
      elsif Screen.for_waiting_to_start? @game.current_screen
        content << interface_text_line(@game.server_url)
        content << interface_line
      else
        content << interface_line
        content << interface_line
      end

      @menu.items.each do |menu_item|
        content << interface_divider
        content << interface_text_line(
          menu_item,
          cursor: @menu.items[@menu.cursor.index] == menu_item,
        )
      end

      unless @alert_message.nil?
        content << interface_text_line(@alert_message)
      end

      content << interface_divider

      number_of_empty_interface_lines.times do
        content << interface_line
      end

      content << interface_bottom_border
    end

    def screen_title
      case @game.current_screen
      when :new_turn
        "Choose Action"
      when :network_url
        "Send Network URL"
      when :network_waiting
        "Network Waiting..."
      when :game_over
        "Choose To"
      when :move_to
        "Moving..."
      when :move
        "Selecting..."
      when :waiting
        "Waiting..."
      when :spot
        "Spot Selected"
      when :start_menu
        "Choose Game Type"
      when :fire
        "Select Player"
      when :firing
        "Firing..."
      when :hit
        "Hit!"
      when :miss
        "Miss!"
      end
    end

    def number_of_empty_interface_lines
      count = (8 - (@menu.items.count * 2))
      count -= 1 unless @alert_message.nil?
      count
    end

    def turn_display
      prefix =
        if current_player.turns_left == 2
          1
        elsif current_player.turns_left == 1
          2
        else
          0
        end
      "(#{prefix} of 2)"
    end

    def interface_text_line(text, cursor: false)
      text = text.to_s
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
