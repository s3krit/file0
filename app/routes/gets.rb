class File0 < Sinatra::Base
  get '/' do
    @pagetype = :form
    erb :base
  end

  get (/^\/([\w]{12}(?:|\.[\w]+))$/) do
    retrieve_file(params['captures'].first)
  end
end
