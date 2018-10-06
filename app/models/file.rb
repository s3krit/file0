# frozen_string_literal: true

require 'pry'
module File0
  class File
    def self.get(path)
      redis = File0::App.redis
      file = redis.get(path)
      return nil unless file

      JSON.parse(file)
    end

    def self.delete(path, key = nil)
      redis = File0::App.redis
      file = redis.get(path)
      return nil unless file

      parsed = JSON.parse(file)
      return nil unless parsed['key'] && (key == parsed['key'])

      redis.del(path)
      true
    end

    def self.ttl(path)
      redis = File0::App.redis
      redis.ttl(path)
    end

    def self.all
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

    def self.create(file, filetype, key = nil, gallery = nil)
      redis = File0::App.redis

      # Early returns for bad shit
      return nil if file.size > File0::Config.max_filesize
      # Identify filetype
      return nil unless valid_file?(file, filetype)

      image_data = file.read
      if image?(filetype)
        thumbnail_data = create_thumbnail(image_data)
        image_data = rotate(image_data)
        image_data = strip(image_data)
      end
      # Store in redis as json {'type':'file/whatever', 'data':'base64'}
      filename = SecureRandom.hex(6) + ::File.extname(file.path)
      payload = {
        filetype: filetype,
        data: Base64.encode64(image_data).delete("\n"),
        key: key,
        thumbnail: thumbnail_data || nil,
        gallery: gallery
      }
      redis.set(filename, payload.to_json)
      redis.expire(filename, File0::Config.lifetime)
      filename
    end

    def self.create_thumbnail(image_data, dimensions = '200x200')
      image = MiniMagick::Image.read(image_data)
      image.resize(dimensions)
      image_data = rotate(image.to_blob)
      Base64.encode64(image_data).delete("\n")
    end

    def self.rotate(image_data)
      image = MiniMagick::Image.read(image_data)
      image.auto_orient.to_blob
    end

    def self.strip(image_data)
      image = MiniMagick::Image.read(image_data)
      image.strip
      image.to_blob
    end

    def self.valid_file?(file, filetype)
      bad_extensions = []
      bad_mimes = []
      extension = ::File.extname(file.path).downcase

      return false if bad_extensions.include?(extension)

      return false if bad_mimes.include?(filetype)

      true
    end

    def self.image?(filetype)
      whitelist = [
        'image/jpeg',
        'image/png',
        'image/gif'
      ]
      whitelist.include?(filetype)
    end

    def self.audio?(filetype)
      whitelist = [
        'audio/mpeg3',
        'audio/mpeg',
        'audio/ogg',
        'video/ogg'
      ]
      whitelist.include?(filetype)
    end
  end
end
