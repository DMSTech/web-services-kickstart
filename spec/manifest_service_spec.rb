require File.dirname(__FILE__) + '/../service/manifest_service.rb'
require 'spec'
require 'spec/interop/test'
require 'rack/test'

set :environment, :test

Test::Unit::TestCase.send :include, Rack::Test::Methods

def app
  Sinatra::Application
end

describe "service" do
  it "should provide a manifest file" do
    get '/manifest/Manifest_kaw-0032.n3'
    last_response.should be_ok
  end
  
  it "should not allow access ouside of the data directory" do
    get '/manifest/../Black_square.jpg'
    last_response.should_not be_ok
  end
end
