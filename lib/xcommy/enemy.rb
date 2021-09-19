module Xcommy
  class Enemy < Entity
    attr_reader :current_destination

    def take_turn!
      clear_turn_cache if @turns.count == 2

      if first_turn? && exposed?
        set_current_destination
        move_to!(next_spot)
      else
        fire_at!(best_player_to_hit)
      end
    end

    def best_player_to_hit
      @game.players.max_by do |player|
        @game.hit_chance_percentage(self, player)
      end
    end

    def set_current_destination
      @current_destination =
        best_spot_behind_cover || best_offensive_spot
    end

    def best_offensive_spot
      # This like the best cover is just a dumb way of determining the spot for right now
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

    def next_spot
      spot = @current_position

      if @current_position[1] < @current_destination[1]
        spot[1] += 1
      elsif @current_position[1] > @current_destination[1]
        spot[1] -= 1
      elsif @current_position[0] < @current_destination[0]
        spot[0] += 1
      elsif @current_position[0] > @current_destination[0]
        spot[0] -= 1
      end
      spot
    end

    def exposed?
      @game.players.any? do |player|
        facing?(player)
      end
    end
  end
end
