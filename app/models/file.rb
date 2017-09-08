require 'pry'
module File0
  class File
    def self.get(path)
      redis = File0::App.redis
      file = redis.get(path)
      return nil unless file
      return JSON.parse(file)
    end

    def self.ttl(path)
      redis = File0::App.redis
      redis.ttl(path)
    end

    def self.get_all
      redis = File0::App.redis
      file_list = redis.keys
      files = []
      file_list.each do |filename|
        file = File0::File.get(filename)
        file['filename'] = filename
        files.push(file)
      end
      files
    end

    def self.size(path)
      file = get(path)
      data = Base64.decode64(file['data'])
      data.size
    end

    def self.create(file,filetype)
      redis = File0::App.redis

      # Early returns for bad shit
      return nil if file.size > File0::Config.max_filesize
      # Identify filetype
      return nil unless is_valid_file?(file,filetype)

      # If it's an application/octet-stream, let's host it as plaintext
      filetype = 'text/plain' if filetype == 'application/octet-stream'
      # Store in redis as json {'type':'file/whatever', 'data':'base64'}
      filename = SecureRandom.hex(6)+::File.extname(file.path)
      payload = {filetype: filetype, data: Base64.encode64(file.read).gsub("\n","")}
      redis.set(filename,payload.to_json)
      redis.expire(filename,File0::Config.max_filesize)
      filename
    end

    def self.is_valid_file?(file,filetype)
      bad_extensions = []
      bad_mimes = []
      extension = ::File.extname(file.path).downcase

      return false if bad_extensions.include?(extension)
      return false if bad_mimes.include?(filetype)
      return true    
    end
  end
end
