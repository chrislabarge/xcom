module Xcommy
  class NPC < Entity
    def missed?
      @miss == true
    end

    def closest_cover
      @game.cover.min_by do |cover_instance|
        Board.distance_between cover_instance.position, current_position
      end
    end

    def take_turn!
      if first_turn? && exposed?
        set_current_destination
        move_to!(next_position)
      else
        fire_at!(best_player_to_hit)
      end
    end

    def first_turn?
      # This @turns_left will need to be extracted out of the Player class
      @turns_left == 2
    end

    def best_player_to_hit
      @game.players.max_by do |player|
        # I moved this into Fired Shot.. will not longer work.
        @game.fired_shot.hit_chance_percentage(self, player)
      end
    end

    def set_current_destination
      @current_destination =
        best_spot_behind_cover || best_offensive_spot
    end

    def best_offensive_spot
      # This like the best cover is just a dumb way of determining the spot for
      # right now

      best_spot = best_player_to_hit.current_position
      best_spot[0] -= 1
      best_spot
    end

    def best_spot_behind_cover
      # This will eventually have to use a mix of "closest cover"
      # and other logic like "unexposed"
      # There will also be cases where I return nil, when no
      # reasonable cover spot is available
      return nil unless closest_cover
      best_spot = closest_cover.position
      best_spot[0] -= 1
      best_spot
    end

    def exposed?
      @game.players.any? do |player|
        facing?(player)
      end
    end
  end
end
