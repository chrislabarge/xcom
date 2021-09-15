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
  end
end
