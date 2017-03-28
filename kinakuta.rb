require 'sinatra'
require 'redis'
require 'pry'

$redis = Redis.new
class Kinakuta < Sinatra::Base

  get '/' do
    erb :index
  end

  post '/upload' do
    # Send shit to create_file
    create_file()
    # Redirect to uploaded file if we get a url, else die?

  end

  def create_file(file)
    # Ingest file
    # Identify filetype
    # Store in redis as json {'type':'file/whatever', 'data':'base64'}
  end
end
