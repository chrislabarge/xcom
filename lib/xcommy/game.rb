module Xcommy
  class Game
    attr_reader :cover
    attr_reader :enemies
    attr_reader :players

    def initialize
      @cover = []
      @enemies = []
      @players = []
    end

    def render
      true
    end

    def closest_cover_to(spot)
      cover.min_by do |cover_instance|
        distance_between cover_instance.position, spot
      end
    end

    # Maybe move into a utilities/calculator files
    def distance_between(spot1, spot2)
      y = spot1[0] - spot2[0]
      x = spot1[1] - spot2[1]

      y.abs + x.abs
    end
  end
end
