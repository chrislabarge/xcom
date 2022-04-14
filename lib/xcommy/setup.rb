module Xcommy
  class Setup
    include Utilities

    attr_accessor :board, :current_screen, :user_interface

    def initialize(server_url: nil)
      @game = Game.new
      @game.npcs = []
      @board = @game.board
      @board.refresh!
      @user_interface = @game.user_interface
      @server_url = server_url

      @game.hit_damage = 30
    end

    def stop!
      @game.stop!
    end

    def start
      @game.current_screen = :start_menu

      if @server_url.nil?
        render(:start_menu)
      else
        @game.players = [
          Player.new(@game, [9, 0], from_local_client: false),
          Player.new(@game, [0, 0], from_local_client: true)
        ]
        @game.server_url = @server_url
        @game.start(:waiting)
        return
      end

      unless Setup.testing?
        next_screen = nil

        loop do
          next_screen = accept_input

          case next_screen
          when :new_turn
            @game.players = [
              Player.new(@game, [9, 0], from_local_client: true),
              Player.new(@game, [0, 0], from_local_client: true)
            ]
            # This has to come after the start menu
            break
          when :network_url
            @game.start_server!
            @game.players = [
              Player.new(@game, [9, 0], from_local_client: true),
              Player.new(@game, [0, 0], from_local_client: false)
            ]
            @game.start_polling!
            break
          end

          render next_screen
        end

        @game.cover = self.class.generate_cover(@game)

        @game.start(next_screen)
      end
    end

    def self.generate_cover(game)
      coords = []

      coords << [8, 3]
      coords << [1, 3]

      coords.map do |coord|
        Cover.new(game, coord, :full_wall)
      end
    end

    def self.testing?
      ENV["TESTING"] == "true"
    end
  end
end
