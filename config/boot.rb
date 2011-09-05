require 'bundler'

ENV["RACK_ENV"] ||= "development"

Bundler.setup
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

Dir["./service/**/*.rb"].each { |f| require f }