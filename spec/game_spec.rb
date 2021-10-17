module Xcommy
  RSpec.describe Game do
    subject! { Setup.new_game }
    before do
      subject.start
    end

    it "begins with player 1 taking a turn" do
      expect(subject.current_player).to eq subject.players.first
      expect(subject.current_screen).to eq :turn
    end

    describe "player 1 turn" do
      describe "'Move' chosen" do
        before do
          subject.mock_input(enter)
        end

        describe "choosing spot above current position" do
          before do
            4.times { subject.mock_input(down) }
            5.times { subject.mock_input(left) }
            subject.mock_input(enter)
          end

          describe "canceling chosen spot" do
            it "reverts to original turn menu" do
              subject.mock_input(down)
              subject.mock_input(enter)
              expect(subject.current_screen).to eq :turn
            end
          end

          describe "confirming chosen spot" do
            it "moves the player" do
              subject.mock_input(enter)
              expect(subject.current_player.current_position).to eq [8, 0]
            end
          end
        end
      end

      describe "'Fire' chosen" do
        before do
          subject.mock_input(down)
          subject.mock_input(enter)
        end

        describe "fire sub-menu" do
          describe "choosing Cancel" do
            it "reverts to original turn menu" do
              subject.mock_input(down)
              subject.mock_input(enter)
              expect(subject.current_screen).to eq :turn
            end
          end

          describe "choosing Enemy 1" do
            let!(:enemy) { subject.enemies.first }
            let!(:fired_shot) { subject.new_fired_shot(at: enemy) }

            before do
              allow(subject).to receive(:fired_shot) { fired_shot }
            end

            it "hits Enemy 1" do
              allow(subject.current_player).to receive(:fire_at!) { :hit }
              subject.mock_input(enter)
              expect(fired_shot.current_position).to eq enemy.current_position
              expect(subject.current_player).to have_received(:fire_at!)
              expect(enemy.health).to be < 100
              expect(subject.current_screen).to eq :turn
            end

            it "misses Enemy 1" do
              allow(subject.current_player).to receive(:fire_at!) { :miss }
              subject.mock_input(enter)
              expect(fired_shot.current_position).to eq enemy.current_position
              expect(subject.current_player).to have_received(:fire_at!)
              expect(enemy.health).to eq 100
              expect(subject.current_screen).to eq :turn
            end
          end
        end
      end
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
