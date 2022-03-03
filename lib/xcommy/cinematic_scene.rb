module Xcommy
  class CinematicScene
    LONG_SLEEP = 0.5
    SHORT_SLEEP = 0.25
    TESTING_SLEEP = 0

    def self.types
      [:move_to, :player_2, :player_1, :hit, :miss]
    end

    def initialize(game)
      @game = game
    end

    def render(scene_type)
      send(scene_type)
    end

    private

    def move_to
      @game.current_player.current_destination = @game.board.cursor.coords

      while !@game.current_player.reached_destination?
        @game.current_player.move_to_next_position!
        @game.board.refresh!

        Screen.new(@game).render(:move_to)

        long_sleep
      end
    end

    def player_2
      fired_shot(@game.other_players[0], :player_2)
    end

    def player_1
      fired_shot(@game.other_players[0], :player_1)
    end

    def short_sleep
      length = Setup.testing? ? TESTING_SLEEP : SHORT_SLEEP
      sleep length
    end

    def long_sleep
      length = Setup.testing? ? TESTING_SLEEP : LONG_SLEEP
      sleep length
    end

    def fired_shot(receiving_entity, type)
      @game.fired_shot = @game.current_player.fire_shot(at: receiving_entity)

      while !@game.fired_shot.reached_destination?
        advance_and_render_fired_shot(type)
      end

      render_fired_shot_outcome(type)

      @game.fired_shot = nil
    end

    def render_fired_shot_outcome(type)
      @game.fired_shot.hide!
      @game.board.refresh!

      Screen.new(@game).render(type)

      long_sleep

      render_player_spot_message(
        @game.fired_shot.at_player,
        @game.fired_shot.result,
      )
    end

    def advance_and_render_fired_shot(type)
      @game.fired_shot.move_to_next_position!
      @game.board.refresh!

      Screen.new(@game).render(type)

      long_sleep
    end

    def render_player_spot_message(player, hit_or_miss)
      render_blinking_player player, hit_or_miss

      2.times do
        player.send("#{hit_or_miss}!")
        @game.board.refresh!
        Screen.new(@game).render(hit_or_miss)
        short_sleep

        # Sending a "hit" to a entity sort of makes sense
        # Sending a "miss" to a entity.. is kind of odd.
        # Why would the entity model need to keep track of a miss
        player.send("reset_#{hit_or_miss}!")

        player.show!
        @game.board.refresh!
        Screen.new(@game).render(hit_or_miss)
        short_sleep
      end

      render_blinking_player player, hit_or_miss
    end

    def render_blinking_player(player, screen_type)
      player.hide!
      @game.board.refresh!
      Screen.new(@game).render(screen_type)
      short_sleep

      player.show!
      @game.board.refresh!
      Screen.new(@game).render(screen_type)
      short_sleep
    end
  end
end
