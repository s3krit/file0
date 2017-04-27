require_relative './base.rb'
module File0
  module Routes
    class Gets < Base
      configure do
        set :views, 'app/views'
        set :root, File.expand_path('../../../', __FILE__)
      end

      get '/' do
        @pagetype = :form
        erb :base
      end

      get (/^\/([\w]{12}(?:|\.[\w]+))$/) do
        path = params['captures'].first
        file = File0::File.get(path)
        unless file
          status 404
          @lifetime = File0::Config.lifetime # Gross...
          @pagetype = :fourohfour
          return erb :base
        end
        content_type file['filetype']
        return Base64.decode64(file['data'])
      end
    end
  end
end
