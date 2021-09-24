require_relative "xcommy/version"
require_relative "xcommy/entity"
require_relative "xcommy/enemy"
require_relative "xcommy/cover"
require_relative "xcommy/game"
require_relative "xcommy/player"
require_relative "xcommy/display"
require_relative "xcommy/spot"

module Xcommy
  class Error < StandardError; end
  game = Game.new
  game.enemies = [Enemy.new(game, [0, 0])]
  game.players = [Player.new(game, [9, 0])]
  game.cover = [
    Cover.new(game, [8, rand(0..9)],:full_wall),
    Cover.new(game, [1, rand(0..9)], :full_wall)
  ]
  game.start
end
