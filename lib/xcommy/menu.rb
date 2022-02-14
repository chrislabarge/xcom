module Xcommy
  class Menu
    def initialize(user_interface)
      @user_interface = user_interface
      @game = user_interface.game
    end

    def options
      case @user_interface.current_screen
      when :spot
        ["Move To", "Cancel"]
      when :move_to
        ["Move To"]
      when :move
        ["Select Spot"]
      when :fire
        options = []
        @game.enemies.each_with_index do |enemy, index|
          options << enemy_option_text
        end

        options << "Cancel"
      when :enemy_1
        [enemy_option_text]
      when :hit
        # TODO - this should come dynamically from the @game.fired_shot model
        [enemy_option_text]
      when :miss
        # TODO - this should come dynamically from the @game.fired_shot model
        [enemy_option_text]
      else
        ["Move", "Fire"]
      end
    end

    def enemy_option_text
      "Enemy 1 (#{@game.enemies[0].health})"
    end
  end
end
