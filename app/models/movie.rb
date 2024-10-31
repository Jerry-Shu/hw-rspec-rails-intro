require 'json'

class Movie < ActiveRecord::Base
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(title)
    return unless title  # Return early if title is nil
    api_key = '8daa8c2fa8548598e7f801ccd743f284'
    uri = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{URI.escape(title)}"
    response = Faraday.get(uri)

    # Parse the JSON response and map it to desired attributes
    movies = JSON.parse(response.body)['results']
    movies.map do |movie|
      {
        title: movie['title'],
        overview: movie['overview'],
        release_date: Date.parse(movie['release_date'])
      }
    end
  end


end
