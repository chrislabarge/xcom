module Xcommy
  class Cover
    attr_reader :position

    def initialize(game, spot)
      @game = game
      @position = spot
    end

    def in_between?(spot1, spot2)
      [:vertically, :horizontally].each do |alignment_type|
        return true if inline_with?(spot1, spot2, alignment_type) &&
          between?(spot1, spot2, alignment_type)
      end
      false
    end

    def inline_with?(spot1, spot2, type)
      index = (type.to_sym == :vertically ? 1 : 0)
      position[index] == spot1[index] && position[index] == spot2[index]
    end

    def between?(spot1, spot2, type)
      index = (type.to_sym == :vertically ? 0 : 1)
      (spot1[index] < position[index] && spot2[index] > position[index] ||
         spot1[index] > position[index] && spot2[index] < position[index])
    end
  end
end
