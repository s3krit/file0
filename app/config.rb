module File0
  class Config < Sinatra::Base
    @lifetime = ENV['FILE0_FILE_LIFETIME'] || 43200
    @max_filesize = ENV['FILE0_MAX_FILESIZE'] || 5000000
    class << self
      attr_accessor :lifetime
      attr_accessor :max_filesize
    end
  end
end
