module Xcommy
  class Entity
    attr_accessor :health, :current_destination, :current_position, :turns_left

    def initialize(game, starting_position)
      @game = game
      @health = 100
      @current_position = starting_position
      @turns_left = 2
      clear_turn_cache
    end

    def fire_at!(entity)
      @game.render(@game.firing_outcome(self, entity))
    end

    def move_to!(position)
      @current_position = position
      #@game.render(:move)
    end

    def completed_turn!
      @turns_left -= 1
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
