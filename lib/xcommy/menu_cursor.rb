module Xcommy
  class MenuCursor
    attr_reader :index

    def initialize(menu)
      @menu = menu
      move_to_top!
    end

    def move_to_top!
      @index = 0
    end

    def move_in(direction)
      if direction == :down
        if @index == 0
          @index = @menu.items.count - 1
        else
          @index -= 1
        end
      else
        if @index == @menu.items.count - 1
          @index = 0
        else
          @index += 1
        end
      end
    end
  end
end
