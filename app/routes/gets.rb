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

      get '/admin' do
        @pagetype = :viewall
        erb :base
      end


      get (/\/([\w]{12}(?:|\.[\w]+))$/), :mustermann_opts => { :check_anchors => false } do
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

      get (/\/([\w]{12}(?:|\.[\w]+))\/delete/) do
        path = params['captures'].first
        res = File0::File.delete(path,session['key'])
        if res
          @pagetype = :deleted
          return erb :base
        else
          status 403
          @pagetype = :forbidden
          return erb :base
        end
      end
    end
  end
end
