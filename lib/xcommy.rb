require_relative "xcommy/version"
require_relative "xcommy/board"
require_relative "xcommy/game"
require_relative "xcommy/entity"
require_relative "xcommy/player"
require_relative "xcommy/enemy"
require_relative "xcommy/fired_shot"
require_relative "xcommy/cover"
require_relative "xcommy/display"
require_relative "xcommy/setup"
require_relative "xcommy/spot"
require_relative "xcommy/user_interface"

module Xcommy
  class Error < StandardError; end
  Setup.new_game.start unless Setup.testing?
end
