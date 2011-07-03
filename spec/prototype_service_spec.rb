require File.dirname(__FILE__) + '/../service/prototype_service.rb'
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
  it "should provide JSON content" do
    get '/prototype/bd017cy0897'
    last_response.should be_ok
  end
    
  it "should provide JSON for the specified FOXML file" do
    get '/prototype/bd017cy0897'
    
    attributes = JSON.parse(last_response.body)["bd017cy0897"]
    attributes.should_not == nil
  end
end
