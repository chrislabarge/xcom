module Xcommy
  class Player < Entity
    def fire_shot(at:)
      FiredShot.new(
        @game,
        current_position,
        at,
      )
    end
  end
end
