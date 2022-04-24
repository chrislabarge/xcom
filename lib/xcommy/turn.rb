require "json"
require "http"

module Xcommy
  class Turn
    attr_accessor :player_index, :type, :position, :id, :game, :damage

    def self.types
      [:move_to, :player_2, :player_1, :hit, :miss]
    end

    def initialize(type: nil, player_index: nil, id: nil, position: nil, game: nil, damage: nil)
      @id = id
      @type = type&.to_sym
      @player_index = player_index
      @game = game
      @damage = damage
      @position = position || find_position
    end

    def at_player
      @game.players[player_index]
    end

    def after_create_screen_type
      return :game_over if @game.over?

      if @game.current_player.from_local_client?
        :new_turn
      else
        :waiting
      end
    end

    def successful?
      @id = new_id

      generate_on_server! if @game.networking?
      # eventually use the return of generate_on_server! to determine if
      # successful

      true
    end

    def self.find(id, game)
      response = HTTP.get("#{game.base_url}/turns?id=#{id}")

      unless response.code.to_s == no_content_code
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
        damage: @damage,
        position: @position,
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
      response = HTTP.post("#{@game.base_url}/turns/new", form: post_params)

      unless response.status.success?
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

      if @type.to_sym == :hit
        content["damage"] = @damage.to_s
      end

      content
    end

    def self.no_content_code
      "204"
    end
  end
end
