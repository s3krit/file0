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
require 'rubygems'
require 'bundler'
require 'securerandom'
require 'base64'
require 'json'

Bundler.require

Dir['./app/*.rb'].each {|f| require f}
Dir['./app/routes/*.rb'].each {|f| require f}

$redis = Redis.new

class File0 < Sinatra::Base
  not_found do
    status 404
    @lifetime = @@lifetime
    @pagetype = :fourohfour
    return erb :base
  end

  def render_generic(title="", body="")
    @title = title
    @body = body
    @pagetype = :generic
    return erb :base
  end
end
