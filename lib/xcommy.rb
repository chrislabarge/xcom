require_relative "xcommy/utilities"
require_relative "xcommy/version"
require_relative "xcommy/board"
require_relative "xcommy/game"
require_relative "xcommy/entity"
require_relative "xcommy/player"
require_relative "xcommy/npc"
require_relative "xcommy/fired_shot"
require_relative "xcommy/cover"
require_relative "xcommy/spot"
require_relative "xcommy/setup"
require_relative "xcommy/menu"
require_relative "xcommy/menu_cursor"
require_relative "xcommy/board_cursor"
require_relative "xcommy/user_interface"
require_relative "xcommy/screen"
require_relative "xcommy/cinematic_scene"
require_relative "xcommy/turn"
require_relative "xcommy/server"

module Xcommy
  class Error < StandardError; end

  server_url = ARGV.first

  Game.new(server_url: server_url).setup_and_start! unless Setup.testing?
end
