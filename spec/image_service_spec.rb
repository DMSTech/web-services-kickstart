require "spec_helper"
require 'json'

describe ImageService do
  
  def app
    @app ||= ImageService
  end
  
  # before(:each) do
  #   app.send(:set, :sessions, true)
  # end
  
  describe "Handling an available sizes request" do
    before(:each) do      
      md =  { :max_width => 4800, :max_height => 2400, :max_levels => 6 }
      dm = DjatokaMetadata.new(md, 'file:///stacks/aa/123/bb/4567/image_003.jp2')
      DjatokaMetadata.should_receive(:find).and_return(dm)
    end
    
    context "normal requests" do
      before(:each) do
        @rights.stub!(:stanford_only?).and_return false
        @rights.stub!(:public?).and_return true
      end
      
      it "serves up the available sizes xml if requested" do
        get '/aa123bb4567/image_003.xml', nil

        last_response.should be_ok
        last_response.body.should =~ /http:\/\/www.w3.org\/1999\/xlink/
        last_response.content_type.should == Rack::Mime.mime_type('.xml')      
      end

      it "serves up the available sizes json if requested" do
        get '/aa123bb4567/image_003.json', nil

        last_response.should be_ok
        j = JSON.parse last_response.body
        j["image"]["formats"]["format"].should include({"mime-type"=>"image/png"})
        last_response.content_type.should == Rack::Mime.mime_type('.json')      
      end
    end
    
    context "restricted images" do
      before(:each) do
        @rights = RightsAuth.new
        RightsAuth.stub!(:find).and_return(@rights)
      end
      
      it "will allow request even if image is not public" do
        @rights.stub!(:stanford_only?).and_return false
        @rights.stub!(:public?).and_return false
        get '/aa123bb4567/image_003.xml', nil

        last_response.should be_ok
        last_response.body.should =~ /http:\/\/www.w3.org\/1999\/xlink/
        last_response.content_type.should == Rack::Mime.mime_type('.xml')
      end
      
      it "does not redirect to webauth if image is stanford-only" do
        @rights.stub!(:stanford_only?).and_return true
        @rights.stub!(:public?).and_return false
        get '/aa123bb4567/image_003.xml', nil

        last_response.should_not be_redirect
        last_response.should be_ok
        last_response.body.should =~ /http:\/\/www.w3.org\/1999\/xlink/
        last_response.content_type.should == Rack::Mime.mime_type('.xml')
      end
    end

  end
  
  describe "Attempt to access stanford-only content from /image path" do
    it "redirects to /image/auth/{druid}/{file}" do
      rights = RightsAuth.new
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(rights)
      rights.stub!(:stanford_only?).and_return true
      
      get '/aa123bb4567/image_0001', nil

      last_response.should be_redirect
      last_response.headers['Location'].should =~ /\/image\/auth\/aa123bb4567\/image_0001/
    end
    
    it "redirects to /image/auth/{druid}/{file} with added params" do
      rights = RightsAuth.new
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(rights)
      rights.should_receive(:stanford_only?).and_return true
      
      get '/aa123bb4567/image_0001?zoom=24', nil

      last_response.should be_redirect
      last_response.headers['Location'].should =~ /\/image\/auth\/aa123bb4567\/image_0001\?zoom=24/
    end
    
    it "redirects to /image/auth/{druid}/{file}.{format} when a file extension passed" do
      rights = RightsAuth.new
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(rights)
      rights.should_receive(:stanford_only?).and_return true
      
      get '/aa123bb4567/image_0001.png?zoom=24', nil

      last_response.should be_redirect
      last_response.headers['Location'].should =~ /\/image\/auth\/aa123bb4567\/image_0001.png\?zoom=24/
    end
    
    context "sessions, webauth, and redirect" do
      it "does not redirect if the user has already webauth'ed" do
        
      end
    end
  end
  
  describe "_thumb and _square requests" do
    
    before(:each) do
      rights = RightsAuth.new
      RightsAuth.should_receive(:find).with('druid:yx205cp5021').and_return(rights)
      rights.should_receive(:stanford_only?).twice.and_return true
      
      app.class_eval do
        helpers do
          def image_service(params)
             200
          end
        end
      end
      
    end
    
    it "always serves these requests to the public" do
      get '/yx205cp5021/image_0001_thumb', nil
              
      last_response.should be_ok
      last_response.should_not be_redirect
    end
    
    it "creates a tempfile in the Sinatra::Application.root directory with the content from Djatoka" do
      pending
      # get '/yx205cp5021/image_0001_thumb', nil
      # 
      # Dir.glob(File.join(Sinatra::Application.root, '..', 'tmp', 'image', '*')).size.should > 0
    end
    
    it "format is the only allowed extra parameter" do
      pending
      # get '/aa123bb4567/image_0001_thumb.png', nil
      # 
      # last_response.should be_ok
    end
  end
  
  describe "/image/auth" do
    
    before(:each) do
      @rights = RightsAuth.new
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(@rights)
    end
    
    it "returns 403 Forbidden if the image is not stanford-only and not public.  Prevents /image/auth from being backdoor to <agent> only images" do
      @rights.should_receive(:stanford_only?).and_return false
      @rights.should_receive(:public?).and_return false
      app.should_not_receive(:image_service)
      
      get '/auth/aa123bb4567/image_00'
      
      last_response.should_not be_ok
      last_response.body.should == "Restricted image"
      last_response.status.should == 403
    end
    
    it "serves up the image if the image is stanford-only" do
      @rights.should_receive(:stanford_only?).and_return true
      @rights.stub!(:public?).and_return false
      
      app.class_eval do
        helpers do
          def image_service(params)
             200
          end
        end
      end
      
      get '/auth/aa123bb4567/image_00'
      last_response.should be_ok
    end
    
    it "serves up the image if this image is public" do
      @rights.should_receive(:stanford_only?).and_return false
      @rights.should_receive(:public?).and_return true
      
      app.class_eval do
        helpers do
          def image_service(params)
             200
          end
        end
      end
      
      get '/auth/aa123bb4567/image_00'
      last_response.should be_ok
    end
  end
  
  describe "world image handling" do
    
    it "returns a 403 error if the image is not stanford-only and not public" do
      rights = RightsAuth.new
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(rights)
      rights.should_receive(:stanford_only?).twice.and_return false
      rights.should_receive(:public?).and_return false
      
      get '/aa123bb4567/image_00', nil

      last_response.should_not be_ok
      last_response.status.should == 403
    end
  end
end