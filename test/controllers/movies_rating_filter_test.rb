require "test_helper"

class MoviesRatingFilterTest < ActionDispatch::IntegrationTest
  setup do
    @g_movie = Movie.create!(title: "Rated G", rating: "G")
    @r_movie = Movie.create!(title: "Rated R", rating: "R")
  end

  test "shows all movies with every rating checked on the first visit" do
    get movies_url

    assert_response :success
    assert_select "form#ratings_form"
    assert_select "input#ratings_submit"
    Movie.all_ratings.each do |rating|
      assert_select "input#ratings_#{rating}[checked]"
    end
    assert_select "#movies > div", count: 2
  end

  test "filters movies and retains checked ratings" do
    get movies_url, params: { ratings: { "R" => "1" } }

    assert_response :success
    assert_select "#movie_#{@r_movie.id}"
    assert_select "#movie_#{@g_movie.id}", count: 0
    assert_select "input#ratings_R[checked]"
    assert_select "input#ratings_G:not([checked])"
  end

  test "shows all movies and checks every rating when no ratings are submitted" do
    get movies_url, params: { ratings: {} }

    assert_response :success
    assert_select "#movies > div", count: 2
    Movie.all_ratings.each do |rating|
      assert_select "input#ratings_#{rating}[checked]"
    end
  end
end
