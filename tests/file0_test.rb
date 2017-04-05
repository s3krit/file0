ENV['RACK_ENV'] = 'test'

require_relative '../file0.rb'
require 'test/unit'
require 'rack/test'

class File0Test < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    File0.new
  end

  def test_it_loads_main_page
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('File0')
  end
end
