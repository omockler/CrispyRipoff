require 'bundler/setup'
require 'sinatra/base'
require 'slim'
require 'json'

class App < Sinatra::Base
  get '/' do
    @images = Dir['public/images/*'].map { |i| i.gsub /public\//, '' }

    slim :index
  end
end
