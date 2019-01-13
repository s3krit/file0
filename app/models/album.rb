# frozen_string_literal: true

require 'pry'
module File0
  class Album
    def self.get(path)
      redis = File0::App.album_redis
      file = redis.get(path)
      return nil unless file

      JSON.parse(file)
    end

    def self.ttl(path)
      redis = File0::App.album_redis
      redis.ttl(path)
    end

    def self.create(files)
      redis = File0::App.album_redis

      # Early returns for bad shit
      return nil if files.size < 2

      album_id = SecureRandom.hex(6)
      payload = {
        files: files
      }
      redis.set(album_id, payload.to_json)
      redis.expire(album_id, File0::Config.lifetime)
      album_id
    end
  end
end
