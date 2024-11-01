Rottenpotatoes::Application.routes.draw do
  resources :movies
  # map '/' to be a redirect to '/movies'
  get '/search', to: 'movies#search_tmdb', as: 'search_tmdb'
  post '/search', to: 'movies#search_tmdb', as: 'search_tmdb_result'

  post '/add_movie', to: 'movies#add_movie', as: 'add_movie'

  root to: redirect('/movies')
end
