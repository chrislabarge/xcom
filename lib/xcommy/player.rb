module Xcommy
  class Player < Entity
    attr_writer :turns_left, :from_local_client

    def initialize(game, starting_position, from_local_client: true)
      super(game, starting_position)
      @from_local_client = from_local_client
    end

    def from_network_client?
      !from_local_client?
    end

    def from_local_client?
      @from_local_client == true
    end

    def turns_left
      @turns_left ||= 2
    end

    def index
      @game.players.index(self)
    end

    def respawn!(starting_position)
      super(starting_position)
      reset_turns_left!
    end

    def fire_shot(at:)
      FiredShot.new(
        @game,
        current_position,
        at,
      )
    end

    def reset_turns_left!
      @turns_left = nil
    end
  end
end
