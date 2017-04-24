class File0 < Sinatra::Base
  @@lifetime = ENV['FILE0_FILE_LIFETIME'] || 43200
  @@max_filesize = ENV['FILE0_MAX_FILESIZE'] || 5000000
end
