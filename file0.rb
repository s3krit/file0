require 'sinatra'
require 'redis'
require 'pry'
require 'base64'
require 'securerandom'
require 'base64'
require 'json'

require_relative './config.rb'

$redis = Redis.new
class File0 < Sinatra::Base

  get '/' do
    @pagetype = :form
    erb :base
  end

  post '/upload' do
    # Send shit to create_file
    file = params['file']
    return render_generic("No file selected","Helps if you select a file, mate") unless file
    uploaded_file = create_file(file[:tempfile],file[:type])
    # Redirect to uploaded file if we get a url, else die?
    return render_generic("Oops!","Something went wrong") unless uploaded_file
    redirect to uploaded_file
  end

  get (/^\/([\w]{12}\.[\w]+)$/) do
    retrieve_file(params['captures'].first)
  end

  not_found do
    status 404
    @lifetime = @@lifetime
    @pagetype = :fourohfour
    return erb :base
  end

  def retrieve_file(path)
    file = $redis.get(path)
    unless file
      status 404
      @lifetime = @@lifetime # Gross...
      @pagetype = :fourohfour
      return erb :base
    end
    parsed_file = JSON.parse(file)
    content_type parsed_file['filetype']
    return Base64.decode64(parsed_file['data'])
  end

  def create_file(file,filetype)
    # Early returns for bad shit
    return nil if file.size > @@max_filesize
    # Identify filetype
    return nil unless is_valid?(file,filetype)
    # Store in redis as json {'type':'file/whatever', 'data':'base64'}
    filename = SecureRandom.hex(6)+File.extname(file.path)
    payload = {filetype: filetype, data: Base64.encode64(file.read).gsub("\n","")}
    $redis.set(filename,payload.to_json)
    $redis.expire(filename,@@lifetime)
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

  def render_generic(title="", body="")
    @title = title
    @body = body
    @pagetype = :generic
    return erb :base
  end
end
