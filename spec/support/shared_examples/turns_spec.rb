RSpec.shared_examples "A Move Turn Type" do |move_to_position|
  let!(:initial_turns_left) { subject.current_player.turns_left }
  let!(:initial_current_player) { subject.current_player }
  let!(:initial_other_player) { subject.other_players.first }

  describe "choosing spot that is blocked" do
    context "by an enemy" do
      before do
        subject.other_players.first.current_position = move_to_position
        subject.board.refresh!
        perform_action
      end

      it "alerts to the spot not being available" do
        expect(subject.user_interface.alert_message)
          .to eq "Spot not available"
      end

      it "maintains turns left" do
        expect(subject.current_player.turns_left).to eq initial_turns_left
      end

      it "maintains move screen" do
        expect(subject.current_screen).to eq :move
      end
    end

    context "by cover" do
      before do
        subject.cover.first.position = move_to_position
        subject.board.refresh!
        perform_action
      end

      it "alerts to the spot not being available" do
        expect(subject.user_interface.alert_message)
          .to eq "Spot not available"
      end

      it "maintains turns left" do
        expect(subject.current_player.turns_left).to eq initial_turns_left
      end

      it "maintains move screen" do
        expect(subject.current_screen).to eq :move
      end
    end
  end

  describe "choosing spot above current position" do
    before do
      perform_action
    end

    describe "canceling chosen spot" do
      before do
        subject.mock_input(down)
        subject.mock_input(enter)
      end

      it "reverts to original turn menu" do
        expect(subject.current_screen).to eq :new_turn
      end

      it "maintains turns left" do
        expect(subject.current_player.turns_left).to eq initial_turns_left
      end
    end

    describe "confirming chosen spot" do
      context "first turn" do
        before do
          subject.mock_input(enter)
        end

        it "moves the player" do
          expect(initial_current_player.current_position)
            .to eq move_to_position
        end

        it "renders the next screen" do
          expect(subject.current_screen).to eq next_screen
        end

        it "takes a turn" do
          if last_turn?
            # it changes players
            expect(subject.current_player).to eq initial_other_player
            expect(subject.current_player.turns_left)
              .to eq 2
          else
            expect(subject.current_player).to eq initial_current_player
            expect(subject.current_player.turns_left)
              .to eq initial_turns_left - 1
          end

          if subject.networking?
            expect_server_generated_turn(id: 2)
          end
        end
      end
    end
  end
end

RSpec.shared_examples "A Fire Turn Type" do |move_to_position|
  let!(:initial_turns_left) { subject.current_player.turns_left }

  describe "fire sub-menu" do
    describe "choosing Cancel" do
      before do
        subject.mock_input(down)
        subject.mock_input(enter)
      end

      it "reverts to original turn menu" do
        expect(subject.current_screen).to eq :new_turn
      end

      it "maintains turns left" do
        expect(subject.current_player.turns_left).to eq initial_turns_left
      end
    end

    describe "choosing other player" do
      let!(:fired_shot) do
        subject.current_player.fire_shot(at: other_player)
      end

      before do
        allow(subject).to receive(:new_fired_shot) { fired_shot }
      end

      describe "HIT" do
        before do
          allow(fired_shot).to receive(:successfully_hit?) { true }
        end

        context "when other player's health is low" do
          before do
            other_player.health = 10
            subject.mock_input(enter)
          end

          it "kills other player" do
            expect(fired_shot.current_position)
              .to eq other_player.current_position
            expect(other_player.health).to eq 0
            expect(subject.current_screen).to eq :game_over
          end

          describe "game over" do
            it "starts a new game" do
              subject.mock_input(enter)
              expect(other_player.health).to eq 100
              expect(subject.current_screen).to eq :new_turn
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

        context "when player 2's health is full" do
          it "reduces health" do
            subject.mock_input(enter)
            expect(fired_shot.current_position)
              .to eq other_player.current_position
            expect(other_player.health).to be < 100
            expect(subject.current_screen).to eq next_screen
            expect(subject.current_player.turns_left).to eq(last_turn? ? 2 : 1)

            expect_server_generated_turn(id: 1) if subject.networking?
          end
        end
      end

      it "MISS" do
        allow(fired_shot).to receive(:successfully_hit?) { false }
        subject.mock_input(enter)
        expect(fired_shot.current_position)
          .to eq other_player.current_position
        expect(other_player.health).to eq 100
        expect(subject.current_screen).to eq next_screen
        expect(subject.current_player.turns_left).to eq(last_turn? ? 2 : 1)
        expect_server_generated_turn(id: 1) if subject.networking?
      end
    end
  end
end

def next_screen
  subject.networking? && last_turn? ? :waiting : :new_turn
end

def last_turn?
  initial_turns_left == 1
end

def expect_server_generated_turn(id: nil)
  sleep(3)
  expect(subject.last_turn.data)
    .to eq Xcommy::Turn.find(id, subject).data
end
