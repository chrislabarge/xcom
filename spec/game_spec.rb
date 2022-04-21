require "./spec/support/shared_examples/turns_spec.rb"

module Xcommy
  RSpec.describe Game do
    include InputHelper

    subject! { Game.new }

    before do
      subject.setup!
    end

    it "begins with a start menu screen" do
      expect(subject.current_screen).to eq :start_menu
    end

    context "when choosing 'Local' play" do
      before do
        subject.mock_input(enter)
      end

      let!(:player_1) { subject.players[0] }
      let!(:player_2) { subject.players[1] }

      it "starts the players on opposing ends of the board" do
        expect(player_1.current_position).to eq [9, 0]
        expect(player_2.current_position).to eq [0, 0]
      end

      it "begins with player 1 taking a turn" do
        expect(subject.current_player).to eq player_1
      end

      # This one is currently failing due to my changes
      it "renders 'new turn' screen" do
        expect(subject.current_screen).to eq :new_turn
      end
    end

    context "when choosing 'Network' play" do
      before do
        subject.mock_input(down)
        subject.mock_input(enter)
        subject.send(:start, :network_url)
      end

      # This will act as a URL presenter and wait screen until other player
      # is ready to go.
      it "provides a URL to send to networked player" do
        expect(subject.current_screen).to eq :network_url
      end

      it "starts a game server" do
        expect(subject.server).not_to eq nil
      end

      context "when choosing 'Sent'" do
        before do
          subject.mock_input(enter)
        end

        it "renders network waiting screen" do
          expect(subject.current_screen).to eq :network_waiting
        end

        context "when choosing 'Cancel'" do
          before do
            subject.mock_input(down)
            subject.mock_input(enter)
          end

          it "renders the start screen" do
            expect(subject.current_screen).to eq :start_menu
          end
        end
      end

      context "when choosing 'Cancel'"do
        before do
          subject.mock_input(down)
          subject.mock_input(enter)
        end

        it "renders the start screen" do
          expect(subject.current_screen).to eq :start_menu
        end
      end
    end
  end
end
