module Xcommy
  class Cover < Entity
    attr_reader :type

    def initialize(game, starting_position, type)
      super(game, starting_position)
      @type = type.to_sym
    end

    def position=(value)
      @current_position = value
    end

    def position
      @current_position
    end

    def in_between?(spot1, spot2)
      [:vertically, :horizontally].each do |alignment_type|
        return true if inline_with?(spot1, spot2, alignment_type) &&
          between?(spot1, spot2, alignment_type)
      end

      false
    end

    def inline_with?(spot1, spot2, alignment_type)
      index = (alignment_type.to_sym == :vertically ? 1 : 0)
      @current_position[index] == spot1[index] && @current_position[index] == spot2[index]
    end

    def between?(spot1, spot2, alignment_type)
      index = (alignment_type.to_sym == :vertically ? 0 : 1)
      (spot1[index] < @current_position[index] && spot2[index] > @current_position[index] ||
         spot1[index] > @current_position[index] && spot2[index] < @current_position[index])
    end
  end
end
