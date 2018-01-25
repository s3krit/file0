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
        file = params['file']
        unless file
          status 400
          return render_generic("No file selected","Helps if you select a file, mate")
        end
        uploaded_file = File0::File.create(file[:tempfile],file[:type], session[:key])
        # Redirect to uploaded file if we get a url, else die?
        unless uploaded_file
          #status 400
          return render_generic("Oops!","Something went wrong")
        end
        render_generic("File uploaded","Take your file mate, it won't be here forever. <a href=#{uploaded_file}>https://#{request.host+"/"+uploaded_file}</a>")
      end
    end
  end
end
