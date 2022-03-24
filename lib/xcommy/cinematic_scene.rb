module Xcommy
  class CinematicScene
    LONG_SLEEP = 0.5
    SHORT_SLEEP = 0.25
    TESTING_SLEEP = 0

    def initialize(game)
      @game = game
    end

    def self.render(turn)
      instance = new(turn.game)
      case turn.type.to_sym
      when :move_to
        instance.move_to(turn.position)
      when :hit
        instance.fired_shot(turn.at_player, :hit)
      when :miss
        instance.fired_shot(turn.at_player, :miss)
      end
    end

    def move_to(position)
      @game.current_player.current_destination = position

      while !@game.current_player.reached_destination?
        @game.current_player.move_to_next_position!
        @game.board.refresh!

        Screen.new(@game).render(:move_to)

        long_sleep
      end
    end

    def fired_shot(receiving_entity, result)
      # this seems sloppy to have here
      @game.fired_shot ||= FiredShot.new(
        @game,
        @game.current_player.current_position,
        receiving_entity,
        result,
      )

      while !@game.fired_shot.reached_destination?
        advance_and_render_fired_shot
      end

      render_fired_shot_outcome(receiving_entity, result)

      @game.fired_shot = nil
    end

    private

    def short_sleep
      length = Setup.testing? ? TESTING_SLEEP : SHORT_SLEEP
      sleep length
    end

    def long_sleep
      length = Setup.testing? ? TESTING_SLEEP : LONG_SLEEP
      sleep length
    end

    def render_fired_shot_outcome(at_player, result)
      @game.fired_shot.hide!
      @game.board.refresh!

      Screen.new(@game).render(:firing)

      long_sleep

      render_player_spot_message(
        at_player,
        result,
      )
    end

    def advance_and_render_fired_shot
      @game.fired_shot.move_to_next_position!
      @game.board.refresh!

      Screen.new(@game).render(:firing)

      long_sleep
    end

    def render_player_spot_message(player, hit_or_miss)
      render_blinking_player player, hit_or_miss

      2.times do
        @game.board.refresh!
        Screen.new(@game).render(hit_or_miss)
        short_sleep

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
