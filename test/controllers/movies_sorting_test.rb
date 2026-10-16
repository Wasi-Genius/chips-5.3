require "test_helper"

class MoviesSortingTest < ActionDispatch::IntegrationTest
  setup do
    @late_movie = Movie.create!(title: "Zebra", rating: "G", release_date: "2020-01-01")
    @early_movie = Movie.create!(title: "!Bang", rating: "G", release_date: "2000-01-01")
    @middle_movie = Movie.create!(title: "Alpha", rating: "R", release_date: "2010-01-01")
  end

  test "sorts by title in Ruby string comparison order" do
    get movies_url, params: { sort_by: "title" }

    assert_response :success
    assert_movie_order(@early_movie, @middle_movie, @late_movie)
    assert_select "select#sort_by option[selected][value='title']"
  end

  test "sorts by release date and retains the rating selection" do
    get movies_url, params: { sort_by: "release_date", ratings: { "G" => "1" } }

    assert_response :success
    assert_movie_order(@early_movie, @late_movie)
    assert_select "select#sort_by option[selected][value='release_date']"
    assert_select "input#ratings_G[checked]"
    assert_select "input#ratings_R:not([checked])"
  end

  test "sort links preserve only the ratings selected in the rendered page" do
    get movies_url, params: { ratings: { "G" => "1" } }

    title_link = css_select("a").find { |link| link.text == "Title" }
    release_date_link = css_select("a").find { |link| link.text == "Release date" }

    assert_includes title_link["href"], "sort_by=title"
    assert_includes title_link["href"], "ratings%5BG%5D=1"
    assert_not_includes title_link["href"], "ratings%5BR%5D"
    assert_includes release_date_link["href"], "sort_by=release_date"
    assert_includes release_date_link["href"], "ratings%5BG%5D=1"
  end

  private

  def assert_movie_order(*movies)
    positions = movies.map { |movie| response.body.index("movie_#{movie.id}") }
    assert_equal positions.sort, positions
  end
end
