require 'spec_helper'
require 'helpers/image_helper.rb'

DRUID = 'aa000bb1111'
IMAGE_NAME = 'np000066'

describe WebServicesKickstart::ImageService do
 
  def app
    @app ||= WebServicesKickstart::ImageService 
  end

  describe "GET image/:druid/:image_square" do
    
    it "should provide a square image region" do
      # get 'http://localhost:4545/image/aa000bb1111/np000066_square'
      get '/image/aa000bb1111/np000066_square'
      last_response.should be_ok
      
      imageHelper = ImageHelper.new(last_response.body)
      imageHelper.exif_info.should_not == nil
      # imageHelper.width.should == imageHelper.height
    end
    
  end
end
