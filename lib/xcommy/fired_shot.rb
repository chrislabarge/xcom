module Xcommy
  class FiredShot < Entity
    attr_accessor :at_player

    def initialize(game, starting_position, player_fired_at)
      @game = game
      @current_position = duplicate_coords starting_position
      @at_player = player_fired_at
      @current_destination = duplicate_coords at_player.current_position
      show!
    end

    def result
      if successfully_hit?
        @at_player.health -= @game.hit_damage
        :hit
      else
        :miss
      end
    end

    def successfully_hit?
      actual_hit_chance_percentage =
        hit_chance_percentage - miss_chance_percentage

      return false if actual_hit_chance_percentage <= 0

      handicap = 10
      rand(1..100) <= actual_hit_chance_percentage + handicap
    end

    private

    def miss_chance_percentage
      distance = Board.distance_between(
        @game.current_player.current_position,
        @at_player.current_position,
      )

      # Test for this
      return 0 if distance == 1

      # TODO: Need to also calculate things like receiving_entity armor
      # Things NOT observable to player

      (distance * 5) + rand(-5..5)
    end

    # TODO - I think I have the miss/hit logic swapped... THe chance
    # percentage, should increase the closer the opposing player are to one
    # another

    def hit_chance_percentage
      # This needs to be static per Turn.. should get cleared on cache?
      # Would need to be a hash/nested array to capture player assignment
      distance = Board.distance_between(
        @game.current_player.current_position,
        @at_player.current_position,
      )

      # Test for this
      return 100 if distance == 1

      # TODO: Need to also calculate things like receiving_entity behind cover
      # Things observable to player

      (distance * 10) + rand(-5..5)
    end
  end
end
