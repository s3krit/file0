# frozen_string_literal: true

module File0
  module Routes
    class Base < Sinatra::Base
      helpers Sinatra::Cookies

      before do
        unless cookies[:key]
          response.set_cookie 'key',
                              value: SecureRandom.hex(32),
                              # 100 years should be long enough...
                              max_age: 60 * 60 * 24 * 365 * 100
        end
      end

      configure do
        set :views, 'app/views'
        set :root, File.expand_path('../..', __dir__)
      end

      def render_generic(title = '', body = '')
        @title = title
        @body = body
        @pagetype = :generic
        erb :base
      end
    end
  end
end
