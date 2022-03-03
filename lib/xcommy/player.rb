module Xcommy
  class Player < Entity
    def turns_left
      2 - @current_turns.count
    end

    def current_turns
      @current_turns ||= []
    end

    def respawn!(starting_position)
      super(starting_position)
      reset_current_turns!
    end

    def fire_shot(at:)
      FiredShot.new(
        @game,
        current_position,
        at,
      )
    end

    def reset_current_turns!
      @current_turns = []
    end
  end
end
