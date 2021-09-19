require_relative "xcommy/version"
require_relative "xcommy/entity"
require_relative "xcommy/enemy"
require_relative "xcommy/cover"
require_relative "xcommy/game"
require_relative "xcommy/player"
require_relative "xcommy/display"

module Xcommy
  class Error < StandardError; end
  game = Game.new
  game.enemies = [Enemy.new(game, [0, 0])]
  game.players = [Player.new(game, [9, 0])]
  game.start
end
