require File.dirname(__FILE__) + '/../service/images_service.rb'
require File.dirname(__FILE__) + '/helpers/image_helper.rb'
require 'spec'
require 'spec/interop/test'
require 'rack/test'

set :environment, :test

DRUID = 'aa000bb1111'
IMAGE_NAME = 'np000066'
# image source location is http://memory.loc.gov/gmd/gmd433/g4330/g4330/np000066.jp2

Test::Unit::TestCase.send :include, Rack::Test::Methods

def app
  Sinatra::Application
end

describe "service" do
  it "should provide a square image region" do
    get 'http://localhost:4545/image/aa000bb1111/np000066_square'
    last_response.should be_ok
    puts "Response is ok"
    imageHelper = ImageHelper.new(last_response.body)
    imageHelper.width.should == imageHelper.height
  end
end
