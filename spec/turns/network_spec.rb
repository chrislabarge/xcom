require "./spec/support/shared_examples/turns_spec.rb"

module Xcommy
  RSpec.describe Turn do
    include InputHelper

    subject! { Setup.new_game }
    let!(:player_1) { subject.players[0] }
    let!(:player_2) { subject.players[1] }

    before do
      subject.start
      allow(player_2).to receive(:from_local_client?) { false }
      subject.start_server!
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

          it_behaves_like("A Move Turn Type", [8, 0], true)
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
          subject.current_player = player_2
        end

        it "renders a waiting screen" do
          expect(subject.current_screen).to eq :waiting
        end

        # this is where I will test all Server responses
      end
    end
  end
end
