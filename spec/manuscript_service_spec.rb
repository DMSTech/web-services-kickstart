require File.dirname(__FILE__) + '/../service/manuscript_service.rb'
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
  it "should provide a manuscript collection" do
    get '/v1/manuscript'
    last_response.should be_ok
    json = JSON.parse(last_response.body)
    json.should_not == nil
    json["manuscripts"].should_not == nil
    2.times { |i|
      json["manuscripts"][i].should == "http//dmstech.stanford.edu/manuscript/#{i + 1}" 
    }    
  end
end
