# frozen_string_literal: true

module File0
  class Config < Sinatra::Base
    # Lifetime of files in seconds
    @lifetime = ENV['FILE0_FILE_LIFETIME'].to_i || 43_200
    # Max filesize in bytes
    @max_filesize = ENV['FILE0_MAX_FILESIZE'].to_i || 5_000_000
    class << self
      attr_accessor :lifetime
      attr_accessor :max_filesize
    end
  end
end
