require "./spec/support/shared_examples/turns_spec.rb"

module Xcommy
  RSpec.describe Turn do
    include InputHelper

    subject! do
      game = Game.new
      game.send(:start, :network_url)
      sleep(2)
      game
    end

    let!(:player_1) { subject.players[0] }
    let!(:player_2) { subject.players[1] }

    it "designates networked player" do
      allow(player_2).to receive(:from_local_client?) { false }
    end

    describe "Player 1" do
      def perform_action
        2.times { subject.mock_input(left) }
        subject.mock_input(enter)
      end

      describe "First turn" do
        describe "MOVE chosen" do
          before do
            subject.mock_input(enter)
          end

          it_behaves_like("A Move Turn Type", [8, 0])
        end

        describe "FIRE chosen" do
          before do
            subject.mock_input(down)
            subject.mock_input(enter)
          end

          it_behaves_like("A Fire Turn Type") do
            let!(:other_player) { player_2 }
          end
        end
      end
    end

    describe "Second turn" do
      before do
        subject.current_player.turns_left -= 1
        subject.last_turn = Turn.new(
          game: subject,
          id: 1,
          type: :miss,
          player_index: 1,
        )
      end

      describe "'Move' chosen" do
        def perform_action
          2.times { subject.mock_input(left) }
          subject.mock_input(enter)
        end

        before do
          subject.mock_input(enter)
        end

        it_behaves_like("A Move Turn Type", [8, 0])
      end

      describe "FIRE chosen" do
        before do
          subject.mock_input(down)
          subject.mock_input(enter)
        end

        it_behaves_like("A Fire Turn Type") do
          let!(:other_player) { player_2 }
        end
      end
    end

    describe "Waiting for networked player" do
      context "when current player is networked" do
        before do
          allow(subject).to receive(:@server_url) { nil }
          subject.current_player = player_2
        end

        it "renders a waiting screen" do
          subject.setup!
          expect(subject.current_screen).to eq :waiting
        end

        context 'when no turn has been taken' do
          before do
            subject.start
            sleep(3)
          end

          it "does not receive turn" do
            expect(subject.last_turn).to eq nil
          end

          it "maintains a waiting screen" do
            expect(subject.current_screen).to eq :waiting
          end
        end

        context 'when a move turn has been taken' do
          let!(:turn) do
            Turn.new(id: 1, type: :move_to, position: [1, 0], game: subject)
          end

          before do
            turn.successful?
            subject.start
            sleep(3)
          end

          it "receives turn" do
            expect(subject.last_turn.data).to eq turn.data
          end

          it "updates player 2's position" do
            expect(player_2.current_position).to eq [1, 0]
          end
        end

        context 'when a hit turn has been taken' do
          let!(:turn) do
            Turn.new(
              id: 1,
              type: :hit,
              damage: subject.hit_damage,
              player_index: 0,
              game: subject
            )
          end

          before do
            turn.successful?
            subject.start
            sleep(3)
          end

          it "receives turn" do
            expect(subject.last_turn.data).to eq turn.data
          end

          it "damages player 1's health" do
            expect(player_1.health).to eq 70
          end
        end

        context 'when a miss turn has been taken' do
          let!(:turn) do
            Turn.new(id: 1, type: :miss, player_index: 0, game: subject)
          end

          before do
            turn.successful?
            subject.start
            sleep(3)
          end

          it "receives turn" do
            expect(subject.last_turn.data).to eq turn.data
          end
        end
      end

      # TODO Verify that when it is 2nd turn, and the turn has been taken,
      # if renders the proper current_screen (:new_turn), and switches players
    end
  end
end
