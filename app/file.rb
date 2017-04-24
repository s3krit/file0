class File0 < Sinatra::Base
  def retrieve_file(path)
    file = $redis.get(path)
    unless file
      status 404
      @lifetime = @@lifetime # Gross...
      @pagetype = :fourohfour
      return erb :base
    end
    parsed_file = JSON.parse(file)
    content_type parsed_file['filetype']
    return Base64.decode64(parsed_file['data'])
  end

  def create_file(file,filetype)
    # Early returns for bad shit
    return nil if file.size > @@max_filesize
    # Identify filetype
    return nil unless is_valid_file?(file,filetype)

    # If it's an application/octet-stream, let's host it as plaintext
    filetype = 'text/plain' if filetype == 'application/octet-stream'
    # Store in redis as json {'type':'file/whatever', 'data':'base64'}
    filename = SecureRandom.hex(6)+File.extname(file.path)
    payload = {filetype: filetype, data: Base64.encode64(file.read).gsub("\n","")}
    $redis.set(filename,payload.to_json)
    $redis.expire(filename,@@lifetime)
    filename
  end

  def is_valid_file?(file,filetype)
    bad_extensions = []
    bad_mimes = []
    extension = File.extname(file.path).downcase

    return false if bad_extensions.include?(extension)
    return false if bad_mimes.include?(filetype)
    return true    
  end
end
