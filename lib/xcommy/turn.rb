require "json"

module Xcommy
  class Turn
    attr_accessor :player_index, :type, :position, :id, :game

    def initialize(type:, player_index: nil, id: nil, position: nil, game: nil)
      @id = id
      @type = type
      @player_index = player_index
      @position = position
      @game = game
    end

    def successful?
      @id = new_id
      @position = find_position

      # I think this networking conditional will have to get moved
      # to the game class... As I will need to know when to render a "Waiting" screen.
      if @game.networking?
        generate_on_server!
      else
        true
      end
    end

    def to_json
      data.to_json
    end

    private

    def new_id
      (@game.last_turn&.id || 0) + 1
    end

    def find_position
      @game.board.cursor.coords
    end

    def generate_on_server!
      #some post request to the server URL.
      #
    end

    def data
      { type: @type,
        player_index: @player_index,
        position: @position }
    end
  end
end
