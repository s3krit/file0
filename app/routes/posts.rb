require_relative './base.rb'
module File0
  module Routes
    class Posts < Base
      configure do
        set :views, 'app/views'
        set :root, File.expand_path('../../../', __FILE__)
      end

      post '/upload' do
        # Send shit to create_file
        files = params['files']
        unless files
          status 400
          return render_generic("No files selected","Helps if you select a file, mate")
        end

        file_urls = []
        files.each do |file|
          file_urls.push File0::File.create(file[:tempfile],file[:type], session[:key])
        end

        # Redirect to uploaded file if we get a url, else die?
        if file_urls.empty?
          status 500
          return render_generic("Oops!","Something went wrong")
        end
        if request.port == 80 then host_string = request.host else host_string = request.host_with_port end
        if file_urls.size == 1
          return render_generic("File uploaded","Take your file mate, it won't be here forever. <a href=#{file_urls.first}>#{request.scheme}://#{host_string+"/"+file_urls.first}</a>")
        else
          body_str = "Take your files mate, they won't be here forever.\n<ul>\n"
          file_urls.each do |url|
            body_str += "<li><a href=#{url}>#{request.scheme}://#{host_string+"/"+url}</a></li>\n"
          end
          body_str += "</ul>\n"
          return render_generic("Files uploaded", body_str)
        end
      end
    end
  end
end
