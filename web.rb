require 'sinatra'
require 'json'
require_relative 'app/get_actor'


configure do
  require 'redis'
  redisUri = ENV["REDISTOGO_URL"] || 'redis://localhost:6379'
  uri = URI.parse(redisUri)
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

get '/' do
  """
  Returns the image of actors from Rotten Tomatoes based on celebrity_id <br>
  Use /:actor_id to get a json with the {'poster_url':} <br>
  Or /image/:actor_id to get redirected to the image
  """
end

get '/:actor' do
  content_type :json
  image = GetActor.query_actor(params[:actor])
  {:poster_url => image}.to_json
end

get '/image/:actor' do
  image = GetActor.query_actor(params[:actor])
  if image
    redirect image
  else
    ''
  end
end

get '/debug/:actor' do
  image = GetActor.query_actor(params[:actor])
  "<img src='#{image}'></img>"
end