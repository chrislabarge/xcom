module Xcommy
  class Player
    attr_reader :current_position

    def initialize(game, starting_position)
      @game = game
      @current_position = starting_position
    end

    # refactor
    #def behind_cover?
    #end

    #def touching_cover?
    #end

    #def exposed?
    #end

    #def facing?(spot1, spot2)
    #end
  end
end
