module Xcommy
  RSpec.describe NPC do
    let!(:game) { Game.new }
    subject { described_class.new(game, [0, 0]) }

    describe "#behind_cover?" do
      it "returns false" do
        expect(subject.behind_cover?).to eq(false)
      end

      context "when touching cover" do
        before do
          allow(game).to receive(:cover) { [Cover.new(game, [1, 0], :full_wall)] }
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

    describe "#fire_at!" do
      let!(:player) { Player.new(game, [9, 1]) }
      before do
        allow(game).to receive(:render)
      end

      context "when hitting player" do
        before do
          allow(game).to receive(:successfully_hit?) { true }
        end

        it "returns 'hit'" do
          actual = subject.fire_at! player
          expect(actual).to eq :hit
        end

        it "reduces player health" do
          subject.fire_at! player
          expect(player.health).to be < 100
        end
      end

      context "when missing a player" do
        before do
          allow(game).to receive(:successfully_hit?) { false }
        end

        it "does change player health" do
          subject.fire_at! player
          expect(player.health).to eq 100
        end

        it "returns 'miss'" do
          actual = subject.fire_at! player
          expect(actual).to eq :miss
        end
      end
    end

    describe "#take_turn!" do
      context "when exposed" do
        let!(:player) { Player.new(game, [9, 1]) }

        before do
          allow(game).to receive(:render)
          allow(game).to receive(:players) { [player] }
        end

        context "when cover exist" do
          before do
            allow(game).to receive(:cover) do
              [Cover.new(game, [4, 2], :full_wall)]
            end
            subject.take_turn!
          end

          it "has a destination currently behind cover" do
            expect(subject.current_destination).to eq([3, 2])
          end

          it "moves to the optimal spot along destination" do
            expect(subject.current_position).to eq([0, 1])
          end
        end

        context "when cover does NOT exist" do
          before do
            allow(subject).to receive(:fire_at!).with(player)
          end

          describe "first turn" do
            before do
              subject.take_turn!
            end

            it "has a destination currently by best player to hit" do
              expect(subject.current_destination).to eq([8, 1])
            end

            it "moves to the optimal spot along destination" do
              expect(subject.current_position).to eq([0, 1])
            end

            it "fires at player" do
              expect(subject).not_to receive(:fire_at!).with(player)
            end
          end

          # NONE of these are working
          describe "second turn" do
            before do
              subject.take_turn!
              subject.take_turn!
              pending "I determine what I am doing"
            end

            it "has a same destination currently by best player to hit" do
              expect(subject.current_destination).to eq([8, 1])
            end

            it "does not move" do
              expect(subject.current_position).to eq([0, 1])
            end

            it "fires at player" do
              expect(subject).to have_received(:fire_at!).with(player)
            end

            it "renders the screen" do
              expect(game).to have_received(:render).with(:move)
            end
          end
        end
      end
    end
  end
end
