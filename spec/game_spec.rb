module Xcommy
  RSpec.describe Game do
    subject! { Setup.new_game }

    describe "player 1 turn" do
      context "when player selects spot to move to" do
        it "moves the player" do
          subject.start
          move_to_spot_above_current_position!
          expect(subject.current_player.current_position).to eq [8, 0]
        end
      end
    end

    def move_to_spot_above_current_position!
      # choose turn type
      subject.mock_input(enter)
      # choose spot
      4.times { subject.mock_input(down) }
      5.times { subject.mock_input(left) }
      subject.mock_input(enter)
      # confirm spot
      subject.mock_input(enter)
    end

    def enter
     "\r"
    end

    def down
     "j"
    end

    def left
     "h"
    end

    def right
     "l"
    end

    def up
     "k"
    end
  end
end
