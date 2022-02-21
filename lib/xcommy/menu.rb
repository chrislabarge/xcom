module Xcommy
  class Menu
    attr_reader :cursor, :game, :current_selection

    def initialize(user_interface)
      @user_interface = user_interface
      @game = user_interface.game
      @cursor = MenuCursor.new(self)
    end

    def select_option!
      @current_selection = highlighted_option
    end

    def current_board_object_selection
      player_index = @current_selection.to_s[-1].to_i - 1
      @game.players[player_index]
    end

    def highlighted_option
      option = options[@cursor.index].gsub(/\s+/, "_").downcase
      spell_checker = DidYouMean::SpellChecker.new(dictionary: ['player_2'])
      (spell_checker.correct(option).first || option).to_sym
    end

    def highlighted_board_object_option
      player_index = highlighted_option.to_s[-1].to_i - 1
      @game.players[player_index]
    end

    def show_cursor!
      if @current_selection == :fire
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
        [fire_at_player_text(current_board_object_selection)]
      when :hit
        [fire_at_player_text(current_board_object_selection)]
      when :miss
        [fire_at_player_text(current_board_object_selection)]
      else
        ["Move", "Fire"]
      end
    end

    private

    def current_selection_is_a_player_object?
      @current_selection.to_s.include?("player")
    end

    def fire_at_player_text(player)
      "#{player.label} (#{player.health})"
    end
  end
end
