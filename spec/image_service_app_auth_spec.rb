require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "/image/app App path authn and authz" do

  def app
    @app ||= ImageService
  end
  
  # before(:each) do
  #   app.send(:set, :sessions, true)
  # end

  it "returns a 401 error if the client does not authenticate" do
    get '/app/aa123bb4567/image_00', nil
    
    last_response.should_not be_ok
    last_response.status.should == 401
  end
  
  it "returns a 401 error if the client sends bad credentials" do
    authorize 'bad', 'boy'
    get '/app/aa123bb4567/image_00', nil
    
    last_response.should_not be_ok
    last_response.status.should == 401
  end
  
  it "returns a 401 error if the client sends valid username but nil password" do
    authorize 'dmstech', nil
    get '/app/aa123bb4567/image_00', nil
    
    last_response.should_not be_ok
    last_response.status.should == 401
  end
  
  it "returns a 401 error if the client sends invalid username and nil password" do
    authorize 'bad', nil
    get '/app/aa123bb4567/image_00', nil
    
    last_response.should_not be_ok
    last_response.status.should == 401
  end

  
  context "valid user" do
    
    before(:each) do
      app.class_eval do
        helpers do          
          def valid_apps
            {'spec-user', 'spec'}
          end
          
          def image_service(params)
             200
          end
        end
      end
      
      authorize 'spec-user', 'spec'
    end
    
    it "serves up image request if rightsMetadata contains world read" do
      rights = RightsAuth.new
      RightsAuth.should_receive(:find).with('druid:yx205cp5021').and_return(rights)
      rights.should_receive(:public?).and_return true
      rights.should_not_receive(:allowed_read_agent?).with('spec-user')
      
      get '/app/yx205cp5021/image_0001_large', nil

      last_response.should be_ok
    end
    
    it "if not world readable, checks if logged in app is an allowed read agent" do
      rights = RightsAuth.new
      RightsAuth.should_receive(:find).with('druid:yx205cp5021').and_return(rights)
      rights.should_receive(:public?).and_return false
      rights.should_receive(:allowed_read_agent?).with('spec-user').and_return true

      get '/app/yx205cp5021/image_0001_large', nil

      last_response.should be_ok
    end

    it "returns a 403 not authorized if agent does not match rights" do
      rights = RightsAuth.new
      RightsAuth.should_receive(:find).with('druid:yx205cp5021').and_return(rights)
      rights.should_receive(:public?).and_return false
      rights.should_receive(:allowed_read_agent?).with('spec-user').and_return false

      get '/app/yx205cp5021/image_0001_large', nil

      last_response.should_not be_ok
      last_response.status.should == 403
    end
    

    it "should serve a thumb request even if the agent does not match rights" do
      rights = RightsAuth.new
      RightsAuth.should_receive(:find).with('druid:yx205cp5021').and_return(rights)
      rights.should_receive(:public?).and_return false
      rights.should_receive(:allowed_read_agent?).with('spec-user').and_return false
      
      get '/app/yx205cp5021/image_0001_thumb', nil

      last_response.should be_ok
      last_response.should_not be_redirect
    end
    
    it "should serve an image-sizes request even if the agent does not match rights" do
      RightsAuth.should_not_receive(:find)      
      md =  { :max_width => 4800, :max_height => 2400, :max_levels => 6 }
      dm = DjatokaMetadata.new(md, 'file:///stacks/aa/123/bb/4567/image_000.jp2')
      DjatokaMetadata.should_receive(:find).and_return(dm)
      
      get '/app/aa123bb4567/image_000.xml', nil

      last_response.should be_ok
      last_response.should_not be_redirect
    end

  end

  
  
end