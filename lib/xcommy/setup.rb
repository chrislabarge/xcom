module Xcommy
  class Setup
    def self.testing?
      ENV["TESTING"] == "true"
    end
  end
end
