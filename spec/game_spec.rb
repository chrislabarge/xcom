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
            before do
              subject.mock_input(down)
              subject.mock_input(enter)
            end

            it "reverts to original turn menu" do
              expect(subject.current_screen).to eq :turn
            end

            it "maintains turns left" do
              expect(subject.turns_left).to eq 2
            end
          end

          describe "confirming chosen spot" do
            context "first turn" do
              before do
                subject.mock_input(enter)
              end

              it "moves the player" do
                expect(subject.current_player.current_position).to eq [8, 0]
              end

              it "renders the turn screen" do
                expect(subject.current_screen).to eq :turn
              end

              it "subtracts a turn" do
                expect(subject.turns_left).to eq 1
              end
            end

            context "second turn" do
              before do
                subject.current_turns = [:move]
                subject.mock_input(enter)
              end

              it "moves the player" do
                expect(subject.current_player.current_position).to eq [8, 0]
              end

              it "renders the NPC turn screen" do
                # How can I verify it is the NPC taking a turn?
                # I should allow the USER to control Enemy 1
                # And then get the game over screen working
                # and opening screen.
                # Then I can attempt doing the AI again.
                expect(subject.current_screen).to eq :turn
              end

              it "subtracts a turn" do
                expect(subject.turns_left).to eq 0
              end
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
            before do
              subject.mock_input(down)
              subject.mock_input(enter)
            end

            it "reverts to original turn menu" do
              expect(subject.current_screen).to eq :turn
            end

            it "maintains turns left" do
              expect(subject.turns_left).to eq 2
            end
          end

          describe "choosing Enemy 1" do
            let!(:enemy) { subject.enemies.first }
            let!(:fired_shot) { subject.new_fired_shot(at: enemy) }

            before do
              allow(subject).to receive(:fired_shot) { fired_shot }
            end

            it "hits Enemy 1" do
              allow(subject).to receive(:successfully_hit?) { true }
              subject.mock_input(enter)
              expect(fired_shot.current_position).to eq enemy.current_position
              expect(enemy.health).to be < 100
              expect(subject.current_screen).to eq :turn
              expect(subject.turns_left).to eq 1
            end

            it "misses Enemy 1" do
              allow(subject).to receive(:successfully_hit?) { false }
              subject.mock_input(enter)
              expect(fired_shot.current_position).to eq enemy.current_position
              expect(enemy.health).to eq 100
              expect(subject.current_screen).to eq :turn
              expect(subject.turns_left).to eq 1
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
