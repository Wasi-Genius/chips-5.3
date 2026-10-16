class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    @all_ratings = Movie.all_ratings
    
    @sort_by = params.key?(:sort_by) ? requested_sort_by : saved_sort_by
    @ratings_to_show = if params.key?(:ratings)
      requested_ratings
    elsif params.key?(:sort_by)
      # The form omits ratings entirely when every checkbox is unchecked.
      @all_ratings
    else
      saved_ratings
    end

    session[:movie_sort_by] = @sort_by
    session[:movie_ratings] = @ratings_to_show
    @ratings_params = @ratings_to_show.index_with { "1" }
    @movies = Movie.with_ratings(@ratings_to_show).order_by(@sort_by)
  end

  # GET /movies/1 or /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated." }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, status: :see_other, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def requested_sort_by
      %w[title release_date].include?(params[:sort_by]) ? params[:sort_by] : "title"
    end


    def saved_sort_by
      %w[title release_date].include?(session[:movie_sort_by]) ? session[:movie_sort_by] : "title"
    end


    def requested_ratings
      ratings = params[:ratings]
      selected_ratings = ratings.respond_to?(:keys) ? ratings.keys & @all_ratings : []

      selected_ratings.presence || @all_ratings
    end


    def saved_ratings
      ratings = session[:movie_ratings]
      selected_ratings = ratings.is_a?(Array) ? ratings & @all_ratings : []
      
      selected_ratings.presence || @all_ratings
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end
