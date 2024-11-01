class MoviesController < ApplicationController
  before_action :force_index_redirect, only: [:index]

  def search_tmdb
    if params[:title].blank? && params[:release_year].blank?
      flash.now[:alert] = "Please enter at least a title or release year to search."
      render :search_tmdb and return
    end

    @movies = Movie.find_in_tmdb(title: params[:title], language: params[:language])

    if params[:release_year].present?
      @movies = @movies.select do |movie|
        movie[:release_date].present? && movie[:release_date].strftime("%Y") == params[:release_year]
      end
    end

    if @movies.empty?
      flash.now[:alert] = "No movies matched your search criteria."
    end

    render :search_tmdb
  end

  def add_movie
    movie_params = {
      title: params[:title],
      release_date: params[:release_date],
      description: params[:overview],
      rating: params[:rating] || 'N/A'  # Default to 'N/A' if rating is not provided
    }

    movie = Movie.new(movie_params)

    if movie.save
      flash[:notice] = "#{movie.title} was successfully added to RottenPotatoes."
    else
      flash[:alert] = "Failed to add #{movie.title} to RottenPotatoes."
    end

    redirect_to search_tmdb_path
  end

  def show
    @movie = Movie.find(params[:id]) # Retrieve movie by unique ID
  end

  def index
    @all_ratings = Movie.all_ratings
    selected_ratings = ratings_list
    sort_column = sort_by || 'id'

    # Fetch movies based on selected ratings and sort order
    @movies = Movie.with_ratings(selected_ratings, sort_column)
    @ratings_to_show_hash = ratings_hash
    @sort_by = sort_column

    # Store ratings and sorting preferences in the session
    session[:ratings] = selected_ratings
    session[:sort_by] = @sort_by
  end

  def new
    # Default render of 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find(params[:id])
  end

  def update
    @movie = Movie.find(params[:id])
    @movie.update!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private

  def force_index_redirect
    # Redirect to include ratings and sort_by in the URL if they are missing
    if !params.key?(:ratings) && !session.key?(:ratings)
      flash.keep
      url = movies_path(sort_by: sort_by, ratings: ratings_hash)
      redirect_to url
    end
  end

  def ratings_list
    # Fetch ratings from params, session, or use default ratings
    (params[:ratings]&.keys || session[:ratings] || Movie.all_ratings).map(&:to_s)
  end

  def ratings_hash
    # Convert ratings list to hash format for URL parameters
    ratings_list.to_h { |rating| [rating, "1"] }
  end

  def sort_by
    # Ensure sort_by parameter is a valid column name
    valid_columns = Movie.column_names
    params[:sort_by] if valid_columns.include?(params[:sort_by])
  end

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
