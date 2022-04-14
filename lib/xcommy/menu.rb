module Xcommy
  class Menu
    attr_reader :cursor, :game, :current_selection

    def initialize(game)
      @game = game
      @cursor = MenuCursor.new(self)
    end

    def select_highlighted_item!
      @current_selection = highlighted_item
    end

    def exit_currently_selected?
      @current_selection == :exit
    end

    def fire_currently_selected?
      @current_selection == :fire
    end

    def cancel_item_highlighted?
      highlighted_item == :cancel
    end

    def highlighted_player_object
      find_player_object highlighted_item
    end

    def items
      case @game.current_screen
      when :start_menu
        ["Local", "Network", "Exit"]
      when :network_url
        ["Sent", "Cancel"]
      when :network_waiting
        ["Waiting", "Cancel"]
      when :spot
        ["Move To", "Cancel"]
      when :move_to
        ["Move To"]
      when :move
        ["Select Spot"]
      when :fire
        fire_items
      when :firing
        [fire_at_player_text(currently_selected_player_object)]
      when :hit
        [fire_at_player_text(currently_selected_player_object)]
      when :miss
        [fire_at_player_text(currently_selected_player_object)]
      when :game_over
        ["Play Again", "Exit"]
      else
        ["Move", "Fire"]
      end
    end

    private

    def highlighted_item
      (item_key items[@cursor.index].gsub(/\s+/, "_").downcase).to_sym
    end

    def currently_selected_player_object
      find_player_object @current_selection
    end

    def find_player_object(player_menu_item)
      player_index = player_menu_item.to_s[-1].to_i - 1
      @game.players[player_index]
    end

    def item_key(str)
      if str.include?("network")
        :network_url
      elsif str.include?("local")
        :new_turn
      elsif str.include?("sent")
        :network_waiting
      elsif str.include?("player_1")
        :player_1
      elsif str.include?("player_2")
        :player_2
      elsif str.include?("play_again")
        @game.restart!
        :new_turn
      else
        str
      end
    end

    def fire_items
      items = []

      @game.other_players.each do |other_player|
        items << fire_at_player_text(other_player)
      end

      items << "Cancel"
    end

    def fire_at_player_text(player)
      "#{player.label} (#{player.health})"
    end
  end
end
