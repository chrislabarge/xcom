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
      # TODO: Update this to make it return objects dynamically
      @game.players[1]
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

        @game.other_players.each do |other_player|
          options << fire_at_player_text(other_player)
        end

        options << "Cancel"
      when :player_2

        # TODO - Update this
        [fire_at_player_text(@game.players[1])]
      when :hit
        # TODO - this should come dynamically from the @game.fired_shot model
        [fire_at_player_text(@game.players[1])]
      when :miss
        # TODO - this should come dynamically from the @game.fired_shot model
        [fire_at_player_text(@game.players[1])]
      else
        ["Move", "Fire"]
      end
    end

    def fire_at_player_text(player)
      # TODO - Fix this label (the number 2 should be coming from `player`)
      "Player 2 (#{player.health})"
    end
  end
end
