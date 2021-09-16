module Xcommy
  RSpec.describe Enemy do
    let!(:game) { Game.new }
    subject { described_class.new(game, [0, 0]) }

    describe "#behind_cover?" do
      it "returns false" do
        expect(subject.behind_cover?).to eq(false)
      end

      context "when touching cover" do
        before do
          allow(game).to receive(:cover) { [Cover.new(game, [1, 0])] }
        end

        context "when unexposed" do
          it "returns true" do
            allow(game).to receive(:players) { [Player.new(game, [9, 0])] }
            expect(subject.behind_cover?).to eq(true)
          end
        end

        context "when exposed" do
          it "returns false" do
            allow(game).to receive(:players) { [Player.new(game, [9, 1])] }
            expect(subject.behind_cover?).to eq(false)
          end
        end
      end

      describe "#take_turn!" do
        context "when exposed" do
          before do
            allow(game).to receive(:players) { [Player.new(game, [9, 1])] }
          end
          context 'when cover exist' do
            before do
              allow(game).to receive(:cover) { [Cover.new(game, [4, 2])] }
              subject.take_turn!
            end

            it "has a destination currently behind cover" do
              expect(subject.current_destination).to eq([3, 2])
            end

            it "moves to the optimal spot along destination" do
              expect(subject.current_position).to eq([0, 1])
            end
          end
        end
      end
    end
  end
end
