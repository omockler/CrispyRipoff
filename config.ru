require 'bundler/setup'
require 'sinatra/base'
require './app'

use Rack::Static, :urls => ['/css', '/js', '/img', '/images', '/fonts'], :root => 'public'

run App.new