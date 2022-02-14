module Xcommy
  RSpec.describe Cover do
    let!(:game) { Game.new }

    describe "#blocked_by_cover?" do
      context "when there is cover in between two spots" do
        describe "vertically" do
          subject { described_class.new(game, [1, 0], :full_wall) }

          it "returns true" do
            expect(subject.in_between?([0, 0], [9, 0])).to eq(true)
          end
        end

        describe "horizontally" do
          subject { described_class.new(game, [0, 1], :full_wall) }
          it "returns true" do
            expect(subject.in_between?([0, 0], [0, 9])).to eq(true)
          end
        end
      end

      context "when there is NO cover in between two spots" do
        describe "vertically" do
          subject { described_class.new(game, [1, 0], :full_wall) }
          it "returns true" do
            expect(subject.in_between?([0, 0], [9, 1])).to eq(false)
          end
        end

        describe "horizontally" do
          subject { described_class.new(game, [0, 1], :full_wall) }
          it "returns true" do
            expect(subject.in_between?([0, 0], [1, 9])).to eq(false)
          end
        end
      end
    end
  end
end
