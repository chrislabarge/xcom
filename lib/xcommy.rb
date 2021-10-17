require_relative "xcommy/version"
require_relative "xcommy/game"
require_relative "xcommy/entity"
require_relative "xcommy/player"
require_relative "xcommy/enemy"
require_relative "xcommy/fired_shot"
require_relative "xcommy/cover"
require_relative "xcommy/display"
require_relative "xcommy/setup"
require_relative "xcommy/spot"

module Xcommy
  class Error < StandardError; end
  Setup.new_game.start unless Setup.testing?
end
