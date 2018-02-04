require_relative './base.rb'
module File0
  module Routes
    class Posts < Base
      configure do
        set :views, 'app/views'
        set :root, File.expand_path('../../../', __FILE__)
      end

      post '/upload' do

        files = params['files']
        unless files
          status 400
          return render_generic("No files selected","Helps if you select a file, mate")
        end

        @file_urls = []
        files.each do |file|
          @file_urls.push File0::File.create(file[:tempfile],file[:type], session[:key])
        end

        # Redirect to uploaded file if we get a url, else die?
        if @file_urls.empty?
          status 500
          return render_generic("Oops!","Something went wrong")
        end
        if request.port == 80 or request.port == 443
          @host_string = request.host
        else
          @host_string = request.host_with_port
        end

        if request.secure?
          @host_string = "https://" + @host_string
        else
          @host_string = "http://" + @host_string
        end

        @pagetype = :uploaded
        return erb :base
      end
    end
  end
end
