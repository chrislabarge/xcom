module Xcommy
  class Board
    def initialize(game)
      @game = game
      @data = {}
      self.class.spot_length.times do |index|
        @data[index] = {}
      end
    end

    def self.spot_length
      10
    end

    def data
      @data
    end

    def refresh!
      fill_board!
    end

    def fill_board!
      @game.players.each_with_index do |player, index|
        next unless player.visible?
        player_coords = player.current_position
        @data[player_coords[0]][player_coords[1]] = "player_#{index + 1}"
      end

      @game.cover.each do |cover|
        cover_coords = cover.position
        @data[cover_coords[0]][cover_coords[1]] = cover.type
      end

      @game.enemies.each_with_index do |enemy, index|
        next unless enemy.visible?
        enemy_coords = enemy.current_position

        @data[enemy_coords[0]][enemy_coords[1]] =
          if enemy.damaged?
            "damage_#{enemy.damage_amount}"
          elsif enemy.missed?
            "miss"
          else
            "enemy_#{index + 1}"
          end
      end

      unless @game.fired_shot.nil? || !@game.fired_shot.visible?
        fired_shot_coords = @game.fired_shot.current_position
        @data[fired_shot_coords[0]][fired_shot_coords[1]] = :fired_shot
      end
    end
  end
end
