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

  def self.find_in_tmdb(params = {})
  title = params[:title]
  language = params[:language] || 'en'
  return unless title

  api_key = '8daa8c2fa8548598e7f801ccd743f284'
  uri = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{URI.encode(title)}&language=#{language}"
  response = Faraday.get(uri)

  movies = JSON.parse(response.body)['results']
  return [] unless movies # Return an empty array if there are no results

  movies.map do |movie|
    {
      title: movie['title'],
      overview: movie['overview'],
      release_date: movie['release_date'].present? ? Date.parse(movie['release_date']) : 'N/A' # Only parse if a valid date exists
    }
  end
end

  

end
