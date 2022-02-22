module Xcommy
  class CinematicScene
    LONG_SLEEP = 0.5
    SHORT_SLEEP = 0.35
    TESTING_SLEEP = 0.0

    def initialize(game, screen)
      @game = game
      @screen = screen
    end

    def self.types
      [:move_to, :player_2, :player_1, :hit, :miss]
    end

    # Try to make this match Screen where we can call #render and pass in the type

    def move_to
      @game.current_player.current_destination = @game.board.cursor.coords
      while !@game.current_player.reached_destination?
        @game.current_player.move_to_next_position!
        @game.board.refresh!

        @screen.render(:move_to)

        long_sleep
      end
    end

    def player_2
      @game.new_fired_shot(at: @game.players[1])

      while !@game.fired_shot.reached_destination?
        @game.fired_shot.move_to_next_position!
        @game.board.refresh!

        @screen.render(:player_2)

        long_sleep
      end

      @game.fired_shot.hide!
      @game.board.refresh!

      @screen.render(:player_2)

      long_sleep

      render_player_spot_message(
        @game.fired_shot.at_player,
        @game.fired_shot.result,
      )

      @game.fired_shot = nil
    end

    def player_1
      @game.new_fired_shot(at: @game.players[0])

      while !@game.fired_shot.reached_destination?
        @game.fired_shot.move_to_next_position!
        @game.board.refresh!

        @screen.render(:player_1)

        long_sleep
      end

      @game.fired_shot.hide!
      @game.board.refresh!

      @screen.render(:player_1)

      long_sleep

      render_player_spot_message(
        @game.fired_shot.at_player,
        @game.fired_shot.result,
      )

      @game.fired_shot = nil
    end

    def render_player_spot_message(player, hit_or_miss)
      render_blinking_player player, hit_or_miss

      2.times do
        player.send("#{hit_or_miss}!")
        @game.board.refresh!
        @screen.render(hit_or_miss)
        short_sleep

        player.send("reset_#{hit_or_miss}!")

        player.show!
        @game.board.refresh!
        @screen.render(hit_or_miss)
        short_sleep
      end

      render_blinking_player player, hit_or_miss
    end

    def render_blinking_player(player, screen_type)
      player.hide!
      @game.board.refresh!
      @screen.render(screen_type)
      short_sleep

      player.show!
      @game.board.refresh!
      @screen.render(screen_type)
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
