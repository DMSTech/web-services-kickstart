require File.dirname(__FILE__) + '/../service/manifest_service.rb'
require 'spec'
require 'spec/interop/test'
require 'rack/test'
require 'json'

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
  
  it "should provide JSON for the manifest files" do
    get '/manifest/Manifest_kaw-0032.json'
    last_response.should be_ok
    
    attributes = JSON.parse(last_response.body)["http://dms.stanford.edu/ns/Manifest"]
    attributes.should_not == nil
  end
end
