module Xcommy
  class Display
    LONG_SLEEP = 0.5
    SHORT_SLEEP = 0.35
    TESTING_SLEEP = 0.0

    attr_accessor :user_interface
    attr_reader :content, :current_screen
    attr_reader :game

    def initialize(game)
      @content = []
      @game = game
      @user_interface = UserInterface.new(@game)
      @current_screen = nil
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
        @user_interface.refresh_alert_message!
        spot_screen
      else option = @user_interface.cursor_selected_menu_option
        unless cinematic_screens.include?(option)
          @user_interface.cursor_index = 0
          @game.board.show_spot_cursor!
        end
        option
      end
    end

    def spot_screen
      if @game.board.cursor_spot.nil?
        :spot
      else
        @user_interface.alert_message = "Spot not available"
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
        @game.board.refresh!
        show! screen(:enemy_1)
        long_sleep
      end

      @game.fired_shot.hide!
      @game.board.refresh!
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
      @game.board.refresh!
      show! screen(:miss)
      short_sleep

      player.reset_miss!

      player.show!
      @game.board.refresh!
      show! screen(:miss)
      short_sleep
    end

    def render_player_damage(player, damage)
      player.damage!(damage)
      @game.board.refresh!
      show! screen(:hit)
      short_sleep

      player.reset_damage!

      player.show!
      @game.board.refresh!
      show! screen(:hit)
      short_sleep
    end

    def render_blinking_player(player, screen_type)
      player.hide!
      @game.board.refresh!
      show! screen(screen_type)
      short_sleep

      player.show!
      @game.board.refresh!
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
      @game.current_player.current_destination = @game.board.cursor_coords
      while !@game.current_player.reached_destination?
        @game.current_player.move_to_next_position!
        @game.board.refresh!
        show! screen(:move_to)
        long_sleep
      end
    end

    def show!(content)
      puts content
    end

    # TODO: Try to extract this into a screen class
    def screen(current)
      @content = []
      @current_screen = current
      5.times do
        content << blank_line
      end
      content << boarder_horizontal
      content << merge_components(
        @game.board.render,
        @user_interface.render(@current_screen)
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

    def change_cursor_position(direction)
      case @game.display.current_screen
      when :move
        @game.board.update_cursor_coords direction
      when :fire
        @user_interface.update_cursor_index direction
      else
        @user_interface.update_cursor_index direction
      end
    end

    def blank_line
      print ""
    end

    def spot_cursor_visible?
      @current_screen == :move || @current_screen == :spot
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
