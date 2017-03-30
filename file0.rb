require 'sinatra'
require 'redis'
require 'pry'
require 'base64'
require 'securerandom'
require 'base64'
require 'json'

$redis = Redis.new
class File0 < Sinatra::Base

  get '/' do
    erb :index
  end

  post '/upload' do
    # Send shit to create_file
    file = params['file']
    uploaded_file = create_file(file[:tempfile],file[:type])
    # Redirect to uploaded file if we get a url, else die?
    return "Oops! Something went wrong" unless uploaded_file
    redirect to uploaded_file
  end

  get (/^\/([\w]{12}\.[\w]+)$/) do
    retrieve_file(params['captures'].first)
  end

  def retrieve_file(path)
    file = $redis.get(path)
    return "404" unless file
    parsed_file = JSON.parse(file)
    content_type parsed_file['filetype']
    return Base64.decode64(parsed_file['data'])
  end

  def create_file(file,filetype)
    # Early returns for bad shit
    return nil if file.size > 10000000
    # Identify filetype
    return nil unless is_valid?(file,filetype)
    # Store in redis as json {'type':'file/whatever', 'data':'base64'}
    filename = SecureRandom.hex(6)+File.extname(file.path)
    payload = {filetype: filetype, data: Base64.encode64(file.read).gsub("\n","")}
    $redis.set(filename,payload.to_json)
    filename
  end

  def is_valid?(file,filetype)
    # Is checking extension even worth it?
    valid_extensions = %w(.png .jpg .jpeg .txt .gif)
    extension = File.extname(file.path)

    valid_mimes = %w{image/jpeg image/png image/gif text/plain}

    return false unless valid_extensions.include?(extension)
    return false unless valid_mimes.include?(filetype)
    return true    
  end
end
