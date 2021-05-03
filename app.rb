# frozen_string_literal: true

# File0 - A temporary image hosting app written in Ruby
# Copyright (C) 2017-2020  Martin Pugh
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
require 'rubygems'
require 'bundler'
require 'securerandom'
require 'base64'
require 'json'
require 'pry'
require 'mini_magick'
require 'filesize'
require 'sinatra/cookies'

Bundler.require

Dir['./app/*.rb'].sort.each { |f| require f }
Dir['./app/routes/*.rb'].sort.each { |f| require f }
Dir['./app/models/*.rb'].sort.each { |f| require f }

module File0
  # Main app class
  class App < Sinatra::Base
    helpers Sinatra::Cookies
    set :views, ::File.dirname(__FILE__) + '/app/views'
    set :public_folder, ::File.dirname(__FILE__) + '/app/public'

    redis_host = ENV['FILE0_REDIS_URL'] || 'localhost'
    redis = Redis.new(host: redis_host)
    # Probably not the best thing to use 2 connections just for namespacing...
    set :file_redis, Redis::Namespace.new(:file, redis: redis)
    set :album_redis, Redis::Namespace.new(:album, redis: redis)
    attr_accessor :file_redis
    attr_accessor :album_redis

    not_found do
      status 404
      @lifetime = Config.lifetime
      @pagetype = :fourohfour
      return erb :base
    end

    configure do
      use Routes::Gets
      use Routes::Posts
    end
  end
end
