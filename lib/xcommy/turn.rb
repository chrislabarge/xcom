require "json"
require "uri"
require "net/http"

module Xcommy
  class Turn
    attr_accessor :player_index, :type, :position, :id, :game

    def self.types
      [:move_to, :player_2, :player_1, :hit, :miss]
    end

    def initialize(type: nil, player_index: nil, id: nil, position: nil, game: nil)
      @id = id
      @type = type&.to_sym
      @player_index = player_index
      @game = game
      @position = position || find_position
    end

    def at_player
      @game.players[player_index]
    end

    def successful?
      @id = new_id

      generate_on_server! if @game.networking?
      # eventually use the return of generate_on_server! to determine if
      # successful

      true
    end

    def self.find(id, game)
      response = Net::HTTP.get_response(
        URI("#{base_url(game)}/turns?id=#{id}"),
      )

      unless response.code == no_content_code
        new(params_from_json(response.body).merge(game: game))
      end
    end

    def to_json
      data.to_json
    end

    def data
      {
        id: id,
        type: @type,
        player_index: @player_index,
        position: @position
      }
    end

    private

    def self.params_from_json(json)
      JSON.parse(json).transform_keys(&:to_sym)
    end

    def new_id
      @game.next_turn_id
    end

    def find_position
      @game&.board&.cursor&.coords
    end

    def generate_on_server!
      uri = URI("#{base_url}/turns/new")

      response = Net::HTTP.post_form(uri, post_params)
      unless response.is_a?(Net::HTTPSuccess)
        sleep(1)
        generate_on_server!
      end
    end

    def post_params
      content = {
        "id" => id.to_s,
        "type" => @type.to_s,
      }

      if !@player_index.nil?
        content["player_index"] = @player_index.to_s
      else
        content["position_y"] = @position[0].to_s
        content["position_x"] = @position[1].to_s
      end

      content
    end

    def base_url
      self.class.base_url @game
    end

    def self.base_url(game)
      "http://#{game.server_url}"
    end

    def self.no_content_code
      "204"
    end
  end
end
