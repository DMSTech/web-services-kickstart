require 'spec_helper'

describe FileService do
  
  def app
    @app ||= FileService
  end
  
  context "normal /file/auth behavior" do
    before(:each) do
      rights = RightsAuth.new
      
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(rights)
      path = File.join('/stacks', 'aa', '123', 'bb', '4567', 'file_name')
      File.should_receive(:exists?).with(path).and_return true
      rights.should_receive(:readable?).and_return true
      rights.should_receive(:public?).and_return true
      rights.stub!(:stanford_only?).and_return false
      
      # Mock call to send_file
      app.class_eval do
        helpers do
          def x_send_file(p)
            p.should == File.join('/stacks', 'aa', '123', 'bb', '4567', 'file_name')
          end
        end
      end
      
      get '/auth/druid:aa123bb4567/file_name', nil, 'WEBAUTH_USER' => 'somesunetid'
    end
    
    it "should respond to /auth/druid:12345/file_name" do
      last_response.should be_ok
    end
    
    it "should test the existence of a file by determining druid tree from id" do
      #expectation in before(:each) block
    end

    it "should check if the object is readable" do
      #expectation in before(:each) block
    end
    
    it "should call send_file to stream the content back" do
      #expectation in before(:each) block
    end
    
  end
  
  context "error handling for the /file/auth path" do
    it "returns a 400 error response if the druid is invalid" do
      get '/auth/druid:invalid1234/file_name', nil, 'WEBAUTH_USER' => 'somesunetid'
      
      last_response.should_not be_ok
      last_response.body.should == "Invalid objectId"
      last_response.status.should == 400
    end
    
    it "returns a 404 error response if the file does not exist" do
      File.stub!(:exists?).and_return false
      get '/auth/druid:aa123bb4567/file_name', nil, 'WEBAUTH_USER' => 'somesunetid'
      
      last_response.should_not be_ok
      last_response.body.should == "File Not Found"
      last_response.status.should == 404
    end
    
    it "returns a 403 Forbidden response if the object is not readable" do
      rights = RightsAuth.new
      
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(rights)
      File.stub!(:exists?).and_return true
      rights.should_receive(:readable?).and_return false
      
      get '/auth/druid:aa123bb4567/file_name', nil, 'WEBAUTH_USER' => 'somesunetid'
            
      last_response.should_not be_ok
      last_response.body.should == "Forbidden"
      last_response.status.should == 403
    end
    
    it "returns a 403 Forbidden response if the object is not public and not stanford-only" do
      rights = RightsAuth.new
      
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(rights)
      File.stub!(:exists?).and_return true
      rights.should_receive(:readable?).and_return true
      rights.should_receive(:stanford_only?).and_return false
      rights.should_receive(:public?).and_return false
      
      get '/auth/druid:aa123bb4567/file_name', nil, 'WEBAUTH_USER' => 'somesunetid'
            
      last_response.should_not be_ok
      last_response.body.should == "Forbidden"
      last_response.status.should == 403
    end
  end
end