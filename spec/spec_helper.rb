ENV["APP_ENV"] = "test"

require_relative "../env"

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
end
