# frozen_string_literal: true

module File0
  class Config < Sinatra::Base
    # Lifetime of files in seconds
    @lifetime = ENV['FILE0_FILE_LIFETIME'].to_i || 43_200
    # Max filesize in bytes
    @max_filesize = ENV['FILE0_MAX_FILESIZE'].to_i || 5_000_000
    # Enable / Disable human readable URLs
    @human_readable_urls = (ENV['FILE0_HUMAN_READABLE_URLS'] || 'true') == 'true'
    class << self
      attr_accessor :lifetime, :max_filesize, :human_readable_urls
    end
  end
end
