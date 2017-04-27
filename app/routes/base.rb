module File0
  module Routes
    class Base < Sinatra::Base
      configure do
        set :views, 'app/views'
        set :root, File.expand_path('../../../', __FILE__)
      end

      def render_generic(title="", body="")
        @title = title
        @body = body
        @pagetype = :generic
        return erb :base
      end
    end
  end
end
