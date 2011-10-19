require File.expand_path(File.dirname(__FILE__) + '/spec_helper')



describe "ImageService session management" do
  
  def app
    @app ||= ImageService
  end
  
  before(:each) do
    @rights = RightsAuth.new
    RightsAuth.should_receive(:find).with('druid:aa123bb4567').and_return(@rights)
    @rights.should_receive(:stanford_only?).and_return true
    @rights.stub!(:public?).and_return false
    
    # Stub out the actual helper that sends the image
    app.class_eval do
      helpers do
        def image_service(params)
           200
        end
      end
    end
 
  end
  
  class SessionData
    def initialize(cookies)
      @cookies = cookies
      @data = cookies['rack.session']
      if @data
        @data = @data.unpack("m*").first
        @data = Marshal.load(@data)
      else
        @data = {}
      end
    end
    
    def [](key)
      @data[key]
    end
    
    def []=(key, value)
      @data[key] = value
      session_data = Marshal.dump(@data)
      session_data = [session_data].pack("m*")
      @cookies.merge("rack.session=#{Rack::Utils.escape(session_data)}", URI.parse("//example.org//"))
      raise "session variable not set" unless @cookies['rack.session'] == session_data
    end
  end
  
  def session
    SessionData.new(rack_test_session.instance_variable_get(:@rack_mock_session).cookie_jar)
  end
    
  describe "/image/auth" do
    it "sets the current webauth user into the session" do
      get '/auth/aa123bb4567/image_00', {}, {'WEBAUTH_USER' => 'user1'}
      last_response.should be_ok
      session[:webauth_user].should == 'user1'
    end
    
    it "does not fail if webauth user is not set (unlikely)" do      
      get '/auth/aa123bb4567/image_00', {}
      last_response.should be_ok
      session[:webauth_user].should be_nil
    end
  end
  
  describe "/image request for stanford-only image and user already webauth'ed" do
    it "does something" do
      pending
      # session[:webauth_user] = 'user1'
      #       get '/aa123bb4567/image_00'
      #       
      #       last_response.should_not be_redirect
      #       last_response.should be_ok
    end
  end
  
end