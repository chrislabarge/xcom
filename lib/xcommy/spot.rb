module Xcommy
  class Spot
    def self.empty
      {
        top: "|    ",
        bottom: "|____",
      }
     end

     def self.cursor
       {
         top: "|ZZZZ",
         bottom: "|ZZZZ",
       }
     end

    def self.for(half, type)
      type ||= :empty
      send(type)[half]
    end
  end
end
