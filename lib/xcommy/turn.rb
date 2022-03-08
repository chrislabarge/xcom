require "json"

module Xcommy
  class Turn
    attr_writer :player_index, :type, :position
    attr_accessor :id

    def initialize(id:, type:, player_index:, position: nil, game: nil)
      @id = id
      @type = type
      @player_index = player_index
      @position = position
      @game = game
    end

    def successful?
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
