module Xcommy
  class Entity
    attr_accessor :health, :current_destination, :current_position, :is_visible, :damage_amount, :miss

    def duplicate_coords(coords)
      [coords[0], coords[1]]
    end

    def initialize(game, starting_position)
      @game = game
      @health = 100
      @damage_amount = 0
      @current_position = starting_position
      clear_turn_cache
      show!
    end

    def hide!
      @is_visible = false
    end

    def show!
      @is_visible = true
    end

    def visible?
      @is_visible == true
    end

    def hit!
      @damage_amount = @game.hit_damage
    end

    def miss!
      @miss = true
    end

    def reset_miss!
      @miss = false
    end

    def missed?
      @miss == true
    end

    def damaged?
      @damage_amount.positive?
    end

    def reset_hit!
      @damage_amount = 0
    end

    def fire_at!(entity)
      @game.firing_outcome(self, entity)
    end

    def move_to!(position)
      @current_position = position
    end

    def move_to_next_position!
      move_to! next_position
    end

    def closest_cover
      @game.closest_cover_to(current_position)
    end

    def in_the_open?
      !touching_cover? && exposed?
    end

    def behind_cover?
      touching_cover? && !exposed?
    end

    def touching_cover?
      @game.cover.any? do |cover|
        touching? @current_position, cover.position
      end
    end

    def touching?(spot1, spot2)
      touching_coords.each do |coord|
        y = (spot2[0].to_i + coord[0])
        x = (spot2[1].to_i + coord[1])

        return true if [y, x] == spot1
      end
    end

    # This is the coordinates for all the spots touching a single spot
    def touching_coords
      [
        [-1, -1],
        [-1, 0],
        [-1, 1],
        [1, 0],
        [0, -1],
        [0, 1],
        [1, -1],
        [1, 1],
      ]
    end

    def clear_turn_cache
      @turns = []
    end

    def facing?(entity)
      @game.cover.none? do |cover|
        cover.in_between?(@current_position, entity.current_position)
      end
    end

    def first_turn?
      @turns.count == 0
    end

    def reached_destination?
      @current_position == @current_destination
    end

    def next_position
      position = current_position

      if current_position[1] < current_destination[1]
        position[1] += 1
      elsif current_position[1] > current_destination[1]
        position[1] -= 1
      elsif current_position[0] < current_destination[0]
        position[0] += 1
      elsif current_position[0] > current_destination[0]
        position[0] -= 1
      end

      position
    end
  end
end
