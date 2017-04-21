# File0 - A temporary image hosting app written in Ruby
# Copyright (C) 2017  Martin Pugh
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
    render_generic("File uploaded","Take your file mate, it won't be here forever. <a href=#{uploaded_file}>https://#{request.host+"/"+uploaded_file}</a>")
  end

  get (/^\/([\w]{12}(?:|\.[\w]+))$/) do
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

    # If it's an application/octet-stream, let's host it as plaintext
    filetype = 'text/plain' if filetype == 'application/octet-stream'
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
    extension = File.extname(file.path).downcase
    valid_mimes = %w{image/jpeg image/png image/gif text/plain application/octet-stream}

    return false unless valid_extensions.include?(extension) or extension.empty?
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
