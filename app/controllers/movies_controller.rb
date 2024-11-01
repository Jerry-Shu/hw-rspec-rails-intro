class MoviesController < ApplicationController
  before_action :force_index_redirect, only: [:index]


  def search_tmdb
    # Step 1: Check if both title and release_year are empty
    if params[:title].blank? && params[:release_year].blank?
      flash.now[:alert] = "Please enter at least a title or release year to search."
      render :search_tmdb and return
    end
  
    # Step 2: Fetch movies from TMDb API
    @movies = Movie.find_in_tmdb(title: params[:title], language: params[:language])
  
    # Step 3: Filter movies by release_year, if provided
    if params[:release_year].present?
      @movies = @movies.select do |movie|
        movie[:release_date].present? && movie[:release_date].strftime("%Y") == params[:release_year]
      end
    end
  
    # Step 4: Check if no movies matched the search criteria
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
      # Optionally, add other default attributes here, like rating
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
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @movies = Movie.with_ratings(ratings_list, sort_by)
    @ratings_to_show_hash = ratings_hash
    @sort_by = sort_by
    # remember the correct settings for next time
    session['ratings'] = ratings_list
    session['sort_by'] = @sort_by
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
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
    return unless !params.key?(:ratings) || !params.key?(:sort_by)

    flash.keep
    url = movies_path(sort_by: sort_by, ratings: ratings_hash)
    redirect_to url
  end

  def ratings_list
    params[:ratings]&.keys || session[:ratings] || Movie.all_ratings
  end

  def ratings_hash
    ratings_list.to_h { |item| [item, "1"] }
  end

  def sort_by
    params[:sort_by] || session[:sort_by] || 'id'
  end
end
