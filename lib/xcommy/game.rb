require 'io/console'
module Xcommy
  class Game
    attr_accessor :cover,
                  :enemies,
                  :players,
                  :current_player,
                  :fired_shot,
                  :hit_damage,
                  :current_turns,
                  :board,
                  :display

    def initialize
      @cover = []
      @enemies = []
      @players = []
      @board = Board.new self
      @current_turns = []
      @fired_shot = nil
      @hit_damage = 10
    end

    def turns_left
      2 - @current_turns.count
    end

    def current_screen
      @display.current_screen
    end

    def start
      @board.refresh!
      @display = Display.new self
      @current_player = players.first
      render(:turn)

      unless Setup.testing?
        loop do
          render accept_input
        end
      end
    end

    def new_fired_shot(at:)
      self.fired_shot = FiredShot.new(
        self,
        current_player.current_position,
        at,
      )
    end

    def render(screen)
      spell_checker = DidYouMean::SpellChecker.new(dictionary: ['enemy_1'])
      parsed_text = spell_checker.correct(screen).first || screen
      @display.render(parsed_text)
    end

    # what accepting a current screen allows for is to keep track of state
    # I think what I should be doing instead is the opposite. Just re-render
    # by default and "refresh" what input is selected/entered by the user
    def accept_input(input = STDIN.getch)
      next_screen = nil
      case input
      when "j"
        @display.change_cursor_position(:down)
      when "k"
        @display.change_cursor_position(:up)
      when "h"
        @display.change_cursor_position(:left)
      when "l"
        @display.change_cursor_position(:right)
      when "\r"
        next_screen = @display.current_selection.downcase.to_sym
      when "c"
        exit
      end
      next_screen || @display.current_screen
    end

    def mock_input(input)
      render accept_input(input)
    end

    def firing_outcome(attempting_entity, receiving_entity)
      if successfully_hit?(attempting_entity, receiving_entity)
        receiving_entity.health -= @hit_damage
        :hit
      else
        :miss
      end
    end

    def successfully_hit?(attempting_entity, receiving_entity)
      actual_hit_chance_percentage =
        hit_chance_percentage(attempting_entity, receiving_entity) -
        miss_chance_percentage(attempting_entity, receiving_entity)

      return false if actual_hit_chance_percentage <= 0

      handicap = 10
      rand(1..100) <= actual_hit_chance_percentage + handicap
    end

    def miss_chance_percentage(entity_firing, entity_receiving)
      distance = distance_between(
        entity_firing.current_position,
        entity_receiving.current_position,
      )

      # Test for this
      return 0 if distance == 1

      # TODO: Need to also calculate things like receiving_entity armor
      # Things NOT observable to player

      (distance * 5) + rand(-5..5)
    end

    # TODO - I think I have the miss/hit logic swapped... THe chance
    # percentage, should increase the closer the opposing player are to one
    # another

    def hit_chance_percentage(entity_firing, entity_receiving)
      # This needs to be static per Turn.. should get cleared on cache?
      # Would need to be a hash/nested array to capture player assignment
      distance = distance_between(
        entity_firing.current_position,
        entity_receiving.current_position
      )

      # Test for this
      return 100 if distance == 1

      # TODO: Need to also calculate things like receiving_entity behind cover
      # Things observable to player

      (distance * 10) + rand(-5..5)
    end

    def closest_cover_to(spot)
      cover.min_by do |cover_instance|
        distance_between cover_instance.position, spot
      end
    end

    # Maybe move into a utilities/calculator files
    def distance_between(spot1, spot2)
      y = spot1[0] - spot2[0]
      x = spot1[1] - spot2[1]

      y.abs + x.abs
    end
  end
end
