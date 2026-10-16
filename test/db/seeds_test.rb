require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  test "running seeds more than once does not create duplicate movies" do
    load Rails.root.join("db/seeds.rb")
    movie_count = Movie.count
    load Rails.root.join("db/seeds.rb")

    assert_equal movie_count, Movie.count
  end
end
