module Xcommy
  class Enemy
    attr_reader :current_position

    def initialize(game, starting_position)
      @game = game
      @current_position = starting_position
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

    def exposed?
      @game.players.any? do |player|
        facing?(player)
      end
    end

    def facing?(player)
      @game.cover.none? do |cover|
        cover.in_between?(@current_position, player.current_position)
      end
    end
  end
end
