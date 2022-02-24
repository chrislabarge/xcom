module Xcommy
  class Player < Entity
    def fire_shot(at:)
      @game.fired_shot = FiredShot.new(
        @game,
        current_position,
        at,
      )
    end
  end
end
