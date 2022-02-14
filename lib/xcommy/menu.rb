module Xcommy
  class Menu
    attr_reader :cursor, :game

    def initialize(user_interface)
      @user_interface = user_interface
      @game = user_interface.game
      @cursor = MenuCursor.new(self)
    end

    def current_selection
      options[@cursor.index].gsub(/\s+/, "_").downcase.to_sym
    end

    def highlighted_board_object_option
      @game.enemies[0]
    end

    def show_cursor!
      if current_selection == :fire
        @game.board.cursor.set_on(
          highlighted_board_object_option.current_position,
        )
      else
        @game.board.cursor.set_on_center_spot
      end

      @cursor.move_to_top
      @game.board.refresh!
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
        @game.enemies.each do |_enemy|
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
