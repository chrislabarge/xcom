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
      @screen = Screen.new(@game, @user_interface)
      @current_screen = nil
    end

    def render(turn_option)
      if Screen.cinematic.include?(turn_option.to_sym)
        send(turn_option)
        @game.current_turns << turn_option
        render(:turn)
      else
        screen_type = turn_option.to_sym
        screen_type = :turn if screen_type == :cancel
        @current_screen = screen_type
        show! @screen.render(screen_type)
      end
    end

    def current_selection
      case @current_screen
      when :move
        @user_interface.refresh_alert_message!
        @screen.spot_screen
      else option = @user_interface.cursor_selected_menu_option
        unless Screen.cinematic.include?(option)
          @user_interface.cursor_index = 0
          @game.board.show_spot_cursor!
        end
        option
      end
    end

    # These are all cinematic instructions for rendering multiple screens for a
    # player to watch. All modeled after the #move_to

    def move_to
      @game.current_player.current_destination = @game.board.cursor_coords
      while !@game.current_player.reached_destination?
        @game.current_player.move_to_next_position!
        @game.board.refresh!
        show! screen(:move_to)
        long_sleep
      end
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

    # These are all screen types below..should get extracted into a new screen_type resource

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

    def show!(content)
      puts content
    end

    # TODO: Try to extract this into a screen class

    def screen(current)
      @current_screen = current
      @screen.render(current)
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

    def spot_cursor_visible?
      @current_screen == :move || @current_screen == :spot
    end

    # These are display controlls. I think they make sense to live in this file

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
