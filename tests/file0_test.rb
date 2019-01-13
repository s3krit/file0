# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'test/unit'
require 'rack/test'
require 'redis'
require 'base64'

class File0Test < Test::Unit::TestCase
  include Rack::Test::Methods
  redis_host = ENV['REDIS_PORT_6379_TCP_ADDR'] || 'localhost'
  redis = Redis.new(host: redis_host)
  $file_redis = Redis::Namespace.new(:file, redis: redis)
  $album_redis = Redis::Namespace.new(:album, redis: redis)

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
    assert_equal 404, last_response.status
  end

  def test_it_throws_404s_on_missing_files
    get '/aaaaaaaaaaaa.jpg'
    assert_equal 404, last_response.status
  end

  def test_it_receives_uploaded_files
    file_count = File0::File.all.size
    post('/upload', "files[]" => Rack::Test::UploadedFile.new('tests/testfile.txt'))
    assert last_response.body.include? 'Take your file'
    assert_equal File0::File.all.size, file_count + 1
  end

  def test_it_receives_multiple_uploaded_files
    file_count = File0::File.all.size
    f = Rack::Test::UploadedFile.new('tests/testfile.txt')
    post('/upload', {files: [f,f]})
    assert last_response.body.include? 'Take your files'
    assert_equal File0::File.all.size, file_count + 2
  end

  def test_it_retrieves_valid_files
    filename = 'bbbbbbbbbbbb.jpg'
    payload = {
      filetype: 'text/plain',
      data: Base64.encode64("Hello, world!\n").strip
    }
    $file_redis.set(filename, payload.to_json)
    get '/bbbbbbbbbbbb.jpg'
    assert last_response.body.include? 'Hello, world'
  end

  def test_it_throws_404s_of_expired_files
    filename = 'bbbbbbbbbbbb.jpg'
    assert $file_redis.get(filename)
    $file_redis.expire(filename, 1)
    sleep 2
    get '/bbbbbbbbbbbb.jpg'
    assert_equal 404, last_response.status
  end

  def test_it_loads_the_gallery_page_correctly
    get '/gallery'
    assert last_response.ok?
    assert last_response.body.include?('Filename')
  end

  def test_gallery_page_lists_approved_files_correctly
    filename = 'bbbbbbbbbbbb.jpg'
    payload = {
      filetype: 'text/plain',
      data: Base64.encode64("Hello, world!\n").strip,
      gallery: 'on'
    }
    $file_redis.set(filename, payload.to_json)
    get '/gallery'
    assert last_response.body.include?('bbbbbbbbbbbb.jpg')
  end

  def test_gallery_page_doesnt_list_unapproved_files
    filename = 'abcdefgh.jpg'
    payload = {
      filetype: 'text/plain',
      data: Base64.encode64("Hello, world!\n").strip,
      gallery: nil
    }
    $file_redis.set(filename, payload.to_json)
    get '/gallery'
    assert !last_response.body.include?('abcdefgh.jpg')
  end

  def test_it_throws_error_on_uploading_no_file
    post '/upload'
    assert_equal 400, last_response.status
  end
end
