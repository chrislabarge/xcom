module Xcommy
  class CinematicScene
    LONG_SLEEP = 0.5
    SHORT_SLEEP = 0.35
    TESTING_SLEEP = 0.0

    def initialize(game, display, screen)
      @game = game
      @display = display
      @screen = screen
    end

    def self.types
      [:move_to, :enemy_1, :hit, :miss]
    end

    # Try to make this match Screen where we can call #render and pass in the type

    def move_to
      @game.current_player.current_destination = @game.board.cursor_coords
      while !@game.current_player.reached_destination?
        @game.current_player.move_to_next_position!
        @game.board.refresh!
        @display.show! @screen.render(:move_to)
        long_sleep
      end
    end

    def enemy_1
      @game.new_fired_shot(at: @game.enemies.first)

      while !@game.fired_shot.reached_destination?
        @game.fired_shot.move_to_next_position!
        @game.board.refresh!
        @display.show! @screen.render(:enemy_1)
        long_sleep
      end

      @game.fired_shot.hide!
      @game.board.refresh!
      @display.show! @screen.render(:enemy_1)
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
      @display.show! @screen.render(:miss)
      short_sleep

      player.reset_miss!

      player.show!
      @game.board.refresh!
      @display.show! @screen.render(:miss)
      short_sleep
    end


    def render_player_damage(player, damage)
      player.damage!(damage)
      @game.board.refresh!
      @display.show! @screen.render(:hit)
      short_sleep

      player.reset_damage!

      player.show!
      @game.board.refresh!
      @display.show! @screen.render(:hit)
      short_sleep
    end

    def render_blinking_player(player, screen_type)
      player.hide!
      @game.board.refresh!
      @display.show! @screen.render(screen_type)
      short_sleep

      player.show!
      @game.board.refresh!
      @display.show! @screen.render(screen_type)
      short_sleep
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
