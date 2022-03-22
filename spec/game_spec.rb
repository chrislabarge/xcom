module Xcommy
  RSpec.describe Game do
    subject! { Setup.new_game }
    let!(:player_1) { subject.players[0] }
    let!(:player_2) { subject.players[1] }

    before do
      subject.start
    end

    it "starts the players on opposing ends of the board" do
      expect(player_1.current_position).to eq [9, 0]
      expect(player_2.current_position).to eq [0, 0]
    end

    it "begins with player 1 taking a turn" do
      expect(subject.current_player).to eq subject.players.first
      expect(subject.current_screen).to eq :new_turn
    end
  end
end
