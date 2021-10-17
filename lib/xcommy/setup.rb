module Xcommy
  class Setup
    def initialize(options)
      @options = options
    end

    def game
      @game = Game.new
      @game.enemies = [Enemy.new(@game, [0, 0])]
      @game.players = [Player.new(@game, [9, 0])]
      @game.cover = generate_cover
      @game
    end

    def self.new_game(options = {})
      self.new(options).game
    end

    def generate_cover
      coords = []

      if self.class.testing?
         coords << [8, 3]
         coords << [1, 3]
      else
         coords << [8, rand(0..9)]
         coords << [1, rand(0..9)]
      end

      coords.map do |coord|
        Cover.new(@game, coord, :full_wall)
      end
    end

    def self.testing?
      ENV["TESTING"] == "true"
    end
  end
end