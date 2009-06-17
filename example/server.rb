require 'rubygems'
require 'sinatra'

#just host static files
set :public, File.dirname(__FILE__)

get '/' do
  "index.html"
end
