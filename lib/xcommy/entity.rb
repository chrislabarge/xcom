module Xcommy
  class Entity
    attr_accessor :health
    attr_reader :current_position

    def initialize(game, starting_position)
      @game = game
      @health = 100
      @current_position = starting_position
      clear_turn_cache
    end

    def fire_at!(entity)
      @turns << :fire_at!
      @game.render(@game.firing_outcome(self, entity))
    end

    def move_to!(spot)
      @current_position = spot
      @turns << :move_to!
      @game.render(:move)
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
  end
end
