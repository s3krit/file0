# frozen_string_literal: true

module File0
  class Config < Sinatra::Base
    @lifetime = ENV['FILE0_FILE_LIFETIME'] || 43_200
    @max_filesize = ENV['FILE0_MAX_FILESIZE'] || 5_000_000
    class << self
      attr_accessor :lifetime
      attr_accessor :max_filesize
    end
  end
end
