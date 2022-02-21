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

    def toggle_static_cursor
      if @game.display.user_interface.menu.highlighted_option == :cancel
        @game.board.cursor.hide!
      else
        @game.board.cursor.set_on(
          @game.display.user_interface.menu.highlighted_board_object_option.current_position,
        )
      end

      @game.board.refresh!
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

      @game.npcs.each_with_index do |npc, index|
        next unless npc.visible?

        npc_coords = npc.current_position

        @data[npc_coords[0]][npc_coords[1]] =
          if npc.damaged?
            "damage_#{npc.damage_amount}"
          elsif npc.missed?
            "miss"
          else
            # This + 2 is just to temp get label correct for now
            "player_#{index + 2}"
          end
      end

      unless @game.fired_shot.nil? || !@game.fired_shot.visible?
        fired_shot_coords = @game.fired_shot.current_position
        @data[fired_shot_coords[0]][fired_shot_coords[1]] = :fired_shot
      end
    end
  end
end
