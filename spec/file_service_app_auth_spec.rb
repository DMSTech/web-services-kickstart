require 'spec_helper'

describe FileService do
  
  def app
    @app ||= FileService
  end
  
  before(:all) do
    app.class_eval do
      helpers do        
        def valid_apps
          {'spec-user', 'spec'}
        end
      end
    end
  end
  
  context "normal /file/app behavior" do
    before(:each) do
      rights = RightsAuth.new
      
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(rights)
      path = File.join('/stacks', 'aa', '123', 'bb', '4567', 'file_name')
      File.should_receive(:exists?).with(path).and_return true
      rights.should_receive(:public?).and_return true
      rights.should_not_receive(:allowed_read_agent?).with('spec-user')
      rights.should_receive(:readable?).and_return true
      
      # Mock call to x_send_file
      app.class_eval do
        helpers do
          def x_send_file(p)
            p.should == File.join('/stacks', 'aa', '123', 'bb', '4567', 'file_name')
          end
        end
      end
      
      authorize 'spec-user', 'spec'
    end
    
    it "should respond to /app/druid:12345/file_name with a valid login" do      
      get '/app/druid:aa123bb4567/file_name'
      
      last_response.should be_ok
    end
    
    
  end
  
  context "exception /file/app behavior" do
    
    it "returns a 404 if RightsMetadata cannot be located for the object" do
      RightsAuth.should_receive(:find).and_return nil
      authorize 'spec-user', 'spec'
      get '/app/druid:zz123yy5678/file_name'
      
      last_response.status.should == 404
      last_response.should_not be_ok
      last_response.body.should =~ /Unable to find RightsMetadata for druid:zz123yy5678/
    end
  end
  
end