module Xcommy
  class Entity
    attr_accessor :health,
                  :current_destination,
                  :current_position,
                  :is_visible,
                  :miss

    def initialize(game, starting_position)
      @game = game
      respawn!(starting_position)
    end

    def respawn!(starting_position)
      @health = 100
      @current_position = starting_position
      show!
    end

    def duplicate_coords(coords)
      [coords[0], coords[1]]
    end

    def alive?
      health.positive?
    end

    def label
      "Player #{ordered_number}"
    end

    def icon
      "P #{ordered_number}"
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

    def damaged?
      @damage_amount.positive?
    end

    def move_to!(position)
      @current_position = position
    end

    def move_to_next_position!
      move_to! next_position
    end

    def behind_cover?
      touching_cover? && !exposed?
    end

    def facing?(entity)
      @game.cover.none? do |cover|
        cover.in_between?(@current_position, entity.current_position)
      end
    end

    def reached_destination?
      @current_position == @current_destination
    end

    private

    def ordered_number
      @game.players.index(self) + 1
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

        return true if spot1 == [y, x]
      end
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
  end
end
