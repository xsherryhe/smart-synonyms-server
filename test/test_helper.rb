ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require 'minitest/spec'
require 'minitest/mock'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class MockSynset
  def as_json
    %w[a b c d e 1 2 3].sample
  end
end

class MockLemma
  def pos
    %w[n v a].sample
  end

  def synsets
    Array.new(3) { MockSynset.new }
  end
end
