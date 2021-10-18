module Xcommy
  class Display
    LONG_SLEEP = 0.5
    SHORT_SLEEP = 0.35
    TESTING_SLEEP = 0.0

    attr_accessor :cursor_index
    attr_reader :content, :current_screen
    attr_reader :game

    def initialize(game)
      @content = []
      @game = game
      @cursor_index = 0
      @current_screen = nil
      refresh_alert_message!
      @board = @game.board
    end

    def render(screen_sym)
      if cinematic_screens.include?(screen_sym.to_sym)
        send(screen_sym)
        @game.current_turns << screen_sym
        render(:turn)
      else
        show! send(screen_sym)
      end
    end

    def current_selection
      case @current_screen
      when :move
        refresh_alert_message!
        spot_screen
      else option = player_options[@cursor_index].gsub(/\s+/, "_").downcase.to_sym
        @board.cursor_select! unless cinematic_screens.include?(option)
        option
      end
    end

    def refresh_alert_message!
      @alert_message = nil
    end

    def spot_screen
      if @board.cursor_spot.nil?
        :spot
      else
        @alert_message = "Spot not available"
        :move
      end
    end

    def spot
      screen(:spot)
    end

    def enemy_1
      @game.new_fired_shot(at: @game.enemies.first)

      while !@game.fired_shot.reached_destination?
        @game.fired_shot.move_to_next_position!
        @board.refresh!
        show! screen(:enemy_1)
        long_sleep
      end

      @game.fired_shot.hide!
      @board.refresh!
      show! screen(:enemy_1)
      long_sleep

      send(@game.fired_shot.result)
      @game.fired_shot = nil
    end

    def miss
      render_blinking_player @game.fired_shot.at_player, :miss
      render_player_message @game.fired_shot.at_player, "Miss"
      render_player_message @game.fired_shot.at_player, "Miss"
      render_blinking_player @game.fired_shot.at_player, :miss
    end

    def hit
      render_blinking_player @game.fired_shot.at_player, :hit
      render_player_damage @game.fired_shot.at_player, 10
      render_player_damage @game.fired_shot.at_player, 10
      @game.fired_shot.at_player.health -= 10
      render_blinking_player @game.fired_shot.at_player, :hit
    end

    def render_player_message(player, damage)
      player.miss!
      @board.refresh!
      show! screen(:miss)
      short_sleep

      player.show!
      @board.refresh!
      show! screen(:miss)
      short_sleep
    end

    def render_player_damage(player, damage)
      player.damage!(damage)
      @board.refresh!
      show! screen(:hit)
      short_sleep

      player.reset_damage!

      player.show!
      @board.refresh!
      show! screen(:hit)
      short_sleep
    end

    def render_blinking_player(player, screen_type)
      player.hide!
      @board.refresh!
      show! screen(screen_type)
      short_sleep

      player.show!
      @board.refresh!
      show! screen(screen_type)
      short_sleep
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

    def fire
      screen(:fire)
    end

    def move_to
      @game.current_player.current_destination = @board.cursor_coords
      while !@game.current_player.reached_destination?
        @game.current_player.move_to_next_position!
        @board.refresh!
        show! screen(:move_to)
        long_sleep
      end
    end

    def show!(content)
      puts content
    end

    def screen(current)
      @content = []
      @current_screen = current
      5.times do
        content << blank_line
      end
      content << boarder_horizontal
      content << merge_components(@board.render, user_interface)
      content << blank_line
      content << boarder_horizontal
      content << blank_line
      content
    end


    def change_cursor_position(direction)
      case @game.display.current_screen
      when :move
        @board.update_cursor_coords direction
      when :fire
        update_cursor_index direction
      else
        update_cursor_index direction
      end
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

    def spot_cursor_visible?
      @current_screen == :move || @current_screen == :spot
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
      interface << interface_text_line(turn_display)

      player_options.each do |option|
        interface << interface_divider
        interface << interface_text_line(option, cursor: player_options[@cursor_index] == option)
      end

      unless @alert_message.nil?
        interface << interface_text_line(@alert_message)
      end

      interface << interface_divider

      number_of_empty_interface_lines.times do
        interface << interface_line
      end

      interface << interface_bottom_border
    end

    def number_of_empty_interface_lines
      count = (8 - (player_options.count * 2))
      count -= 1 unless @alert_message.nil?
      count
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

    def player_options
      case @current_screen
      when :spot
        ["Move To", "Cancel"]
      when :move_to
        ["Move To"]
      when :move
        ["Select Spot"]
      when :fire
        options = []
        @game.enemies.each_with_index do |enemy, index|
          options << enemy_option_text
        end

        options << "Cancel"
      when :enemy_1
        [enemy_option_text]
      when :hit
        # TODO - this should come dynamically from the @game.fired_shot model
        [enemy_option_text]
      when :miss
        # TODO - this should come dynamically from the @game.fired_shot model
        [enemy_option_text]
      else
        ["Move", "Fire"]
      end
    end

    def enemy_option_text
      "Enemy 1 (#{@game.enemies[0].health})"
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

    def cinematic_screens
      [:move_to, :enemy_1, :hit, :miss]
    end

    def long_sleep
      sleep(
        if Setup.testing?
          TESTING_SLEEP
        else
          LONG_SLEEP
        end
      )
    end

    def short_sleep
      sleep(
        if Setup.testing?
          TESTING_SLEEP
        else
          SHORT_SLEEP
        end
      )
    end
  end
end
