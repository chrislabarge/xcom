module Xcommy
  RSpec.describe Game do
    subject! { Setup.new_game }
    let!(:player_1) { subject.players[0] }
    let!(:player_2) { subject.players[1] }

    before do
      subject.start
    end

    it "begins with player 1 taking a turn" do
      expect(subject.current_player).to eq subject.players.first
      expect(subject.current_screen).to eq :turn
    end

    it "starts the players on opposing ends of the board" do
      expect(player_1.current_position).to eq [9, 0]
      expect(player_2.current_position).to eq [0, 0]
    end

    describe "player 1 turn" do
      describe "'Move' chosen" do
        before do
          subject.mock_input(enter)
        end

        describe "choosing spot above current position" do
          before do
            3.times { subject.mock_input(down) }
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
                expect(subject.current_player.current_position).to eq [7, 0]
              end

              it "renders the turn screen" do
                expect(subject.current_screen).to eq :turn
              end

              it "subtracts a turn" do
                # This turns left will have to be rethought
                expect(subject.turns_left).to eq 1
              end
            end

            context "second turn" do
              before do
                subject.current_turns = [:move]
                subject.mock_input(enter)
              end

              it "moves the player" do
                expect(subject.players[0].current_position).to eq [7, 0]
              end

              it "switches to Player 2's turn" do
                expect(subject.current_player).to eq subject.players[1]
              end

              it "renders the turn screen for Player 2" do
                expect(subject.current_screen).to eq :turn
              end

              it "empties the turns" do
                expect(subject.current_turns).to be_empty
              end

              describe "player 2's turn" do
                context "moving" do
                  describe "choosing spot below current position" do
                    before do
                      subject.mock_input(enter)

                      2.times { subject.mock_input(up) }
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
                          expect(subject.players[1].current_position).to eq [2, 0]
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
                          expect(subject.players[1].current_position).to eq [2, 0]
                        end

                        it "switches to Player 1's turn" do
                          expect(subject.current_player).to eq player_1
                        end

                        it "renders the turn screen for Player 1" do
                          expect(subject.current_screen).to eq :turn
                        end

                        it "empties the turns" do
                          expect(subject.current_turns).to be_empty
                        end
                      end
                    end
                  end
                end

                context "firing" do
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

                    describe "choosing Player 1" do
                      let!(:fired_shot) { subject.new_fired_shot(at: player_1) }

                      before do
                        allow(subject).to receive(:fired_shot) { fired_shot }
                      end

                      it "hits Player 1" do
                        allow(subject).to receive(:successfully_hit?) { true }
                        subject.mock_input(enter)
                        expect(fired_shot.current_position).to eq player_1.current_position
                        expect(player_1.health).to be < 100
                        expect(subject.current_screen).to eq :turn
                        expect(subject.turns_left).to eq 1
                      end

                      it "misses Player 1" do
                        allow(subject).to receive(:successfully_hit?) { false }
                        subject.mock_input(enter)
                        expect(fired_shot.current_position)
                          .to eq player_1.current_position
                        expect(player_1.health).to eq 100
                        expect(subject.current_screen).to eq :turn
                        expect(subject.turns_left).to eq 1
                      end
                    end
                  end
                end
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

          describe "choosing Player 2" do
            let!(:player_2) { subject.players[1] }
            let!(:fired_shot) { subject.new_fired_shot(at: player_2) }

            before do
              allow(subject).to receive(:fired_shot) { fired_shot }
            end

            describe "hits player 2" do
              before do
                allow(subject).to receive(:successfully_hit?) { true }
              end

              context "when player 2's health was low" do
                before do
                  player_2.health = 10
                  subject.mock_input(enter)
                end

                it "kills player 2" do
                  expect(fired_shot.current_position).to eq player_2.current_position
                  expect(player_2.health).to eq 0
                  expect(subject.current_screen).to eq :game_over
                end

                describe "game over" do
                  it "starts a new game" do
                    subject.mock_input(enter)
                    expect(player_2.health).to eq 100
                    expect(subject.current_screen).to eq :turn
                    expect(subject.current_player).to eq player_1
                  end

                  it "exits the game" do
                    allow(@game).to receive(:exit)
                    subject.mock_input(down)
                    subject.mock_input(enter)
                    expect(@game).to have_received(:exit)
                  end
                end
              end

              context "when player 2's health was full" do
                it "reduces health" do
                  subject.mock_input(enter)
                  expect(fired_shot.current_position).to eq player_2.current_position
                  expect(player_2.health).to be < 100
                  expect(subject.current_screen).to eq :turn
                  expect(subject.turns_left).to eq 1
                end
              end
            end

            it "misses Player 2" do
              allow(subject).to receive(:successfully_hit?) { false }
              subject.mock_input(enter)
              expect(fired_shot.current_position).to eq player_2.current_position
              expect(player_2.health).to eq 100
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
