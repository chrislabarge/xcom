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
    end
  end
end
