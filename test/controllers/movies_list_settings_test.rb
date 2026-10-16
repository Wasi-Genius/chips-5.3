require "test_helper"

class MoviesListSettingsTest < ActionDispatch::IntegrationTest
  setup do
    @g_movie = Movie.create!(title: "Rated G", rating: "G", release_date: "2020-01-01")
    @other_g_movie = Movie.create!(title: "Another G", rating: "G", release_date: "2000-01-01")
    @r_movie = Movie.create!(title: "Rated R", rating: "R", release_date: "2010-01-01")
  end


  test "restores sort and ratings after returning from a movie" do
    get movies_url, params: { sort_by: "release_date", ratings: { "G" => "1" } }
    assert_response :success

    get movie_url(@g_movie)
    assert_response :success

    get movies_url

    assert_response :success
    assert_select "select#sort_by option[selected][value='release_date']"
    assert_select "input#ratings_G[checked]"
    assert_select "input#ratings_R:not([checked])"
    positions = [@other_g_movie, @g_movie].map { |movie| response.body.index("movie_#{movie.id}") }
    assert_equal positions.sort, positions
    assert_select "#movie_#{@r_movie.id}", count: 0
  end

  
  test "clearing every rating shows and remembers all ratings" do
    get movies_url, params: { sort_by: "release_date", ratings: { "G" => "1" } }
    get movies_url, params: { sort_by: "title" }

    assert_response :success
    assert_select "#movie_#{@g_movie.id}"
    assert_select "#movie_#{@r_movie.id}"
    assert_select "select#sort_by option[selected][value='title']"

    get movies_url

    assert_response :success
    assert_select "#movie_#{@g_movie.id}"
    assert_select "#movie_#{@r_movie.id}"
    assert_select "select#sort_by option[selected][value='title']"
    Movie.all_ratings.each do |rating|
      assert_select "input#ratings_#{rating}[checked]"
    end
  end
end
