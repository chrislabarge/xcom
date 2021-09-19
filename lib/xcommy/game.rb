module Xcommy
  class Game
    attr_reader :cover
    attr_reader :enemies
    attr_reader :players

    def initialize
      @cover = []
      @enemies = []
      @players = []
    end

    def render
      true
    end

    def firing_outcome(attempting_entity, receiving_entity)
      if successfully_hit?(attempting_entity, receiving_entity)
        receiving_entity.health -= 10
        :hit
      else
        :miss
      end
    end

    def successfully_hit?(attempting_entity, receiving_entity)
      actual_hit_chance_percentage =
        hit_chance_percentage(attempting_entity, receiving_entity) -
        miss_chance_percentage(attempting_entity, receiving_entity)

      return false if actual_hit_chance_percentage <= 0

      handicap = 10
      rand(1..100) <= actual_hit_chance_percentage + handicap
    end

    def miss_chance_percentage(entity_firing, entity_receiving)
      distance = distance_between(
        entity_firing.current_position,
        entity_receiving.current_position
      )

      # Test for this
      return 0 if distance == 1

      (distance * 5) + rand(-5..5)
    end

    # TODO - I think I have the miss/hit logic swapped... THe chance
    # percentage, should increase the closer the opposing player are to one
    # another

    def hit_chance_percentage(entity_firing, entity_receiving)
      # This needs to be static per Turn.. should get cleared on cache?
      # Would need to be a hash/nested array to capture player assignment
      distance = distance_between(
        entity_firing.current_position,
        entity_receiving.current_position
      )

      (distance * 10) + rand(-5..5)
    end

    def closest_cover_to(spot)
      cover.min_by do |cover_instance|
        distance_between cover_instance.position, spot
      end
    end

    # Maybe move into a utilities/calculator files
    def distance_between(spot1, spot2)
      y = spot1[0] - spot2[0]
      x = spot1[1] - spot2[1]

      y.abs + x.abs
    end
  end
end
