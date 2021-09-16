module Xcommy
  class Enemy
    attr_reader :current_position, :current_destination

    def initialize(game, starting_position)
      @game = game
      @current_position = starting_position
    end

    def take_turn!
      if exposed?
        set_current_destination
        move_to!(next_spot)
      else
        fire_at!(best_player_to_hit)
      end
    end

    def move_to!(spot)
      @current_position = spot
      @game.render
    end

    def fire_at!(player)
      # calculate the distance and use hit percentage to randomly
      # determine how much damage was dealt
    end

    def best_player_to_hit
      @game.players.max_by do |player|
        hit_chance_percentage(player)
      end
    end

    def set_current_destination
      @current_destination =
        best_spot_behind_cover || best_offensive_spot
    end

    def best_spot_behind_cover
      # This will eventually have to use a mix of "closest cover"
      # and other logic like "unexposed"
      # There will also be cases where I return nil, when no
      # reasonable cover spot is available
      best_spot = closest_cover.position
      best_spot[0] -= 1
      best_spot
    end

    def closest_cover
      @game.closest_cover_to(current_position)
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
