class File0 < Sinatra::Base
  post '/upload' do
    # Send shit to create_file
    file = params['file']
    unless file
      status 400
      return render_generic("No file selected","Helps if you select a file, mate")
    end
    uploaded_file = create_file(file[:tempfile],file[:type])
    # Redirect to uploaded file if we get a url, else die?
    unless uploaded_file
      #status 400
      return render_generic("Oops!","Something went wrong")
    end
    render_generic("File uploaded","Take your file mate, it won't be here forever. <a href=#{uploaded_file}>https://#{request.host+"/"+uploaded_file}</a>")
  end
end
