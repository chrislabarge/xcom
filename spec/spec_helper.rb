require "bundler/setup"
require "support/input_helper.rb"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  ENV["TESTING"] = "true"
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# NOTE: This require has to be below the configuration as I immediately fire up
# a game right now.

require "xcommy"
