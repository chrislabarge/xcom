module Xcommy
  class FiredShot < Entity
    attr_accessor :at_player

    def initialize(game, starting_position, player_fired_at)
      @game = game
      @current_position = duplicate_coords starting_position
      @at_player = player_fired_at
      @current_destination = duplicate_coords at_player.current_position
      show!
    end

    def result
      @game.current_player.fire_at! @at_player
    end
  end
end
