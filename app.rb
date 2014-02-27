Bundler.require

class App < Sinatra::Base

  get '/' do
    @images = Dir['public/images/*'].map { |i| i.gsub /public\//, '' }.shuffle

    slim :index
  end
end
