require 'rubygems'
require 'sinatra'

# setting up the environment
env_index = ARGV.index("-e")
env_arg = ARGV[env_index + 1] if env_index
env = env_arg || ENV["SINATRA_ENV"] || "development"

# image service (with file extension)
get '/image/:id/:filename_:constraint' do
  send_file File.dirname(__FILE__) + '/samples/Black_square.jpg',  :type => :jpg
end

