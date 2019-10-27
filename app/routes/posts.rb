# frozen_string_literal: true

require_relative './base.rb'
module File0
  module Routes
    class Posts < Base
      configure do
        set :views, 'app/views'
        set :root, File.expand_path('../..', __dir__)
      end

      post '/upload' do
        files = params['files']

        unless files
          status 400
          return render_generic(
            'No files selected',
            'Helps if you select a file, mate'
          )
        end

        @file_urls = []
        files.each do |file|
          @file_urls.push File0::File.create(
            file[:tempfile],
            file[:type],
            cookies[:key],
            params['gallery']
          )
        end

        @album_id = File0::Album.create(@file_urls) if files.size > 1

        # Redirect to uploaded file if we get a url, else die?
        if @file_urls.empty?
          status 500
          return render_generic('Oops!', 'Something went wrong')
        end
        @host_string = if (request.port == 80) || (request.port == 443)
                         request.host
                       else
                         request.host_with_port
                       end

        if request.referer == ""
          @host_string = if request.secure?
                           'https://' + @host_string
                         else
                           'http://' + @host_string
                         end
        else
          @host_string = if request.referrer =~ /^https.*/
                           'https://' + @host_string
                         else
                           'http://' + @host_string
                         end
        end

        @pagetype = :uploaded
        return erb :base
      end
    end
  end
end
