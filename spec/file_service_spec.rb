require 'spec_helper'

# TODO need to configure apache for
# WebAuthLdapAttribute suPrivilegeGroup
# WebAuthLdapSeparator Directive
# This will enable read of stanford: privgroups
# Might be an issue for workgroup manager priv groups
# aa111bb2222

describe FileService do

  def app
    @app ||= FileService
  end
      
  describe "GET /:druid/:file_name" do
    before(:each) do
      rights = RightsAuth.new
      
      @path = File.join('/stacks', 'aa', '123', 'bb', '4567', 'file_name')
      File.should_receive(:exists?).and_return true #.with(path).and_return true
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(rights)
      rights.should_receive(:readable?).and_return true
      rights.should_receive(:stanford_only?).and_return false
      rights.should_receive(:public?).and_return true
      
      # Mock call to x_send_file
      app.class_eval do
        helpers do
          def x_send_file(p)
            p.should == File.join('/stacks', 'aa', '123', 'bb', '4567', 'file_name')
          end
        end
      end
      
      get '/druid:aa123bb4567/file_name', nil, 'WEBAUTH_USER' => 'somesunetid'
    end
    
    context "normal behavior" do
      
      it "responds to /druid:12345/file_name" do
        last_response.should be_ok
      end

      it "checks if user is authorized for druid/file" do
        #expectation in before(:each) block
      end

      it "tests the existence of a file by determining druid tree from id" do
        #expectation in before(:each) block
      end

      it "calls send_file to stream the content back" do
        #expectation in before(:each) block
      end
      
      it "sends the file if the file is readable, not stanford-only, and public" do
        #expectation in before(:each) block
      end
      
    end
        
  end
  
  context "Attempt to access stanford-only content from /file path" do
    before(:each) do
      rights = RightsAuth.new
      
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(rights)
      File.stub!(:exists?).and_return true
      rights.should_receive(:readable?).and_return true
      rights.should_receive(:stanford_only?).and_return true
      
      get '/druid:aa123bb4567/file_name', nil
    end
    
    it "redirects to /file/auth/{druid}/{file}" do
      last_response.should be_redirect
      last_response.headers['Location'].should =~ /\/file\/auth\/druid:aa123bb4567\/file_name/
    end
  end
  
  context "error handling for the /file unauthenticated path" do
    before(:each) do
      @rights = RightsAuth.new
      
      RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(@rights)
      File.stub!(:exists?).and_return true
    end
    
    it "returns a 403 Forbidden if the content is unreadable (no access='read' block)" do
      @rights.should_receive(:readable?).and_return false
      get '/druid:aa123bb4567/file_name', nil
      
      last_response.should_not be_ok
      last_response.body.should == "Forbidden"
      last_response.status.should == 403
    end
    
    it "returns a 403 Forbidden if the object is not stanford-only and not public (agent auth only)" do
      @rights.should_receive(:readable?).and_return true
      @rights.should_receive(:stanford_only?).and_return false
      @rights.should_receive(:public?).and_return false
      
      get '/druid:aa123bb4567/file_name', nil
      
      last_response.should_not be_ok
      last_response.body.should == "Forbidden"
      last_response.status.should == 403
    end
  end
    
end