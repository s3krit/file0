ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'test/unit'
require 'rack/test'
require 'redis'
require 'base64'

class File0Test < Test::Unit::TestCase
  include Rack::Test::Methods
  $redis = Redis.new

  def app
    File0::App.new
  end

  # Page loading

  def test_it_loads_main_page
    get '/'
    assert last_response.ok?
    assert last_response.body.include?('File0')
  end

  def test_it_throws_a_404
    get '/thispageshouldneverexist'
    assert_equal 404,last_response.status
  end

  def test_it_throws_404s_on_missing_files
    get '/aaaaaaaaaaaa.jpg'
    assert_equal 404,last_response.status
  end

  def test_it_retrieves_valid_files
    filename = 'bbbbbbbbbbbb.jpg'
    payload= {
               filetype: 'text/plain',
               data: Base64.encode64("Hello, world!\n").strip
    }
    $redis.set(filename,payload.to_json)
    get '/bbbbbbbbbbbb.jpg'
    assert last_response.body.include? 'Hello, world'#
  end

  def test_it_throws_404s_of_expired_files
    filename = 'bbbbbbbbbbbb.jpg'
    assert $redis.get(filename)
    $redis.expire(filename,1)
    sleep 2
    get '/bbbbbbbbbbbb.jpg'
    assert_equal 404,last_response.status
  end

  def test_it_throws_error_on_uploading_no_file
    post '/upload'
    assert_equal 400,last_response.status
  end
end
