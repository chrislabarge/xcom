module Xcommy
  class BoardCursor
    attr_reader :coords

    def initialize(board)
      @board = board
      @game = @board.game
      @coords = []
      @anchor = nil
    end

    def visible?
      [:move, :spot, :fire].include? @game.current_screen
    end

    def set_on_current_player_perimeter
      @coords = @game.board.positions_within_player_perimeter.last
    end

    def hide!
      @coords = []
    end

    def set_on(spot_coords)
      @coords[0] = spot_coords[0]
      @coords[1] = spot_coords[1]
    end

    def move_in(direction)
      case direction
      when :up
        new_position = [@coords[0] - 1, @coords[1]]
      when :down
        new_position = [@coords[0] + 1, @coords[1]]
      when :left
        new_position = [@coords[0], @coords[1] - 1]
      when :right
        new_position = [@coords[0], @coords[1] + 1]
      end

      if @board.position_within_player_perimeter?(new_position)
        @coords = new_position
      end
    end

    def spot_display_type(spot_coords)
      if @coords[1] == spot_coords[1]
        if @coords[0] == spot_coords[0] + 1
          :top_cursor
        elsif @coords[0] == spot_coords[0] - 1
          :bottom_cursor
        end
      elsif @coords[0] == spot_coords[0]
        if @coords[1] == spot_coords[1] + 1
          :left_cursor
        elsif @coords[1] == spot_coords[1] - 1
          :right_cursor
        end
      end
    end
  end
end
