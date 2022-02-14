module Xcommy
  class BoardCursor
    attr_reader :coords

    def initialize(board)
      @board = board
      @game = @board.game
      @coords = []
    end

    def visible?
      [:move, :spot, :fire].include? @game.display.current_screen
    end

    def spot
      @board.data[@coords[0]][@coords[1]]
    end

    # Not being used
    def set_on_center_spot
      @coords = [4, 5]
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
        @coords[0] -= 1 unless @coords[0] == 0
      when :down
        @coords[0] += 1 unless @coords[0] == (Board.spot_length - 1)
      when :left
        @coords[1] -= 1 unless @coords[1] == 0
      when :right
        @coords[1] += 1 unless @coords[1] == (Board.spot_length - 1)
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
