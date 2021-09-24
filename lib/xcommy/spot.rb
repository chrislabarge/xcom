module Xcommy
  class Spot
    def self.empty
      {
        top: "|    ",
        bottom: "|____",
      }
    end

    def self.enemy_1
      {
        top: "| E1 ",
        bottom: "|____",
      }
    end

    def self.player_1
      {
        top: "| P1 ",
        bottom: "|____",
      }
    end

    def self.full_wall
      {
        top: "|ZZZZ",
        bottom: "|ZZZZ",
      }
    end

    def self.half_wall
      {
        top: "|    ",
        bottom: "|ZZZZ",
      }
    end

    def self.top_cursor
      {
        top: empty[:top],
        bottom: "|_VV_",
      }
    end

    def self.left_cursor
      {
        top: "|   >",
        bottom: "|___>",
      }
    end

    def self.right_cursor
      {
        top: "|<   ",
        bottom: "|<___",
      }
    end

    def self.bottom_cursor
      {
        top: "| ^^ ",
        bottom: empty[:bottom],
      }
    end

    def self.for(half, type)
      type ||= :empty
      send(type)[half]
    end
  end
end
