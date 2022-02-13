module Xcommy
  class Board
    attr_reader :cursor
    attr_reader :game
    attr_reader :data

    def initialize(game)
      @game = game
      @data = {}
      @cursor = BoardCursor.new(self)
    end

    def self.spot_length
      10
    end

    def refresh!
      fill_board!
    end

    def render
      rows = []
      rows << Array.new(self.class.spot_length, "_____").join + "_"
      self.class.spot_length.times do |outer_index|
        top = []
        bottom = []

        self.class.spot_length.times do |inner_index|
          spot_type = find_spot_type [outer_index, inner_index]
          top << Spot.for(:top, spot_type).to_s
          bottom << Spot.for(:bottom, spot_type).to_s
        end

        rows << top.join + "|"
        rows << bottom.join + "|"
      end
      rows
    end

    private

    def find_spot_type(spot_coords)
      board_spot = @data[spot_coords[0]][spot_coords[1]]

      return board_spot unless @game.board.cursor.visible?

      board_spot || @cursor.spot_display_type(spot_coords)
    end

    def fill_board!
      self.class.spot_length.times do |index|
        @data[index] = {}
      end

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
