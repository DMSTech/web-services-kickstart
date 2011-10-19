require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RightsAuth do
  before(:all) do
    RIGHTS_MD_SERVICE_URL = 'http://purl-test.stanford.edu'
  end
  
  describe "#stanford_only?" do
    
    it "returns true if the object has stanford-only read access" do
      rights =<<-EOXML
      <objectType>
        <rightsMetadata>
          <access type="read">
            <machine>
              <group>stanford</group>
            </machine>
          </access>
        </rightsMetadata>
      </objectType>
      EOXML
      RestClient.stub!(:get).and_return(rights)
      
      h = RightsAuth.fetch_and_build('bd186zk8210')
      r = RightsAuth.new(h)
      r.stanford_only?.should be_true
    end
    
    it "returns false if the object does not have stanford-only read access" do
      rights =<<-EOXML
      <objectType>
        <rightsMetadata>
          <access type="read">
            <machine>
              <world />
            </machine>
          </access>
        </rightsMetadata>
      </objectType>
      EOXML
      RestClient.stub!(:get).and_return(rights)
      
      h = RightsAuth.fetch_and_build('bd186zk8210')
      rights = RightsAuth.new(h)
      rights.stanford_only?.should be_false
    end
  end
  
  describe "#public?" do
    
    it "returns true if this object has world readable visibility" do
      rights =<<-EOXML
      <objectType>
        <rightsMetadata>
          <access type="read">
            <machine>
              <world />
            </machine>
          </access>
        </rightsMetadata>
      </objectType>
      EOXML
      RestClient.stub!(:get).and_return(rights)
      
      h = RightsAuth.fetch_and_build('bd186zk8210')
      r = RightsAuth.new(h)
      r.public?.should be_true
    end
    
    it "returns false if there is no machine readable world visibility" do
      rights =<<-EOXML
      <objectType>
        <rightsMetadata>
          <access type="read">
            <machine>
              <group>stanford:stanford</group>
            </machine>
          </access>
        </rightsMetadata>
      </objectType>
      EOXML
      RestClient.stub!(:get).and_return(rights)
      
      h = RightsAuth.fetch_and_build('bd186zk8210')
      r = RightsAuth.new(h)
      r.public?.should be_false
    end
    
    it "returns false if the rights metadata does not contain a read block" do
      rights =<<-EOXML
      <objectType>
        <rightsMetadata>
        <access type="discover">
          <machine>
            <world />
          </machine>
        </access>
        </rightsMetadata>
      </objectType>
      EOXML
      RestClient.stub!(:get).and_return(rights)
      
      h = RightsAuth.fetch_and_build('bd186zk8210')
      r = RightsAuth.new(h)
      r.public?.should be_false
    end
    
  end
  
  describe "#readable?" do
    
    it "returns true if the rights metadata contains a read block" do
      rights =<<-EOXML
      <objectType>
        <rightsMetadata>
          <access type="read">
            <machine>
              <world />
            </machine>
          </access>
        </rightsMetadata>
      </objectType>
      EOXML
      RestClient.stub!(:get).and_return(rights)
      
      h = RightsAuth.fetch_and_build('bd186zk8210')
      r = RightsAuth.new(h)
      r.readable?.should be_true
    end
    
    it "returns false if the rights metadata does not contain a read block" do
      rights =<<-EOXML
      <objectType>
        <rightsMetadata>
          <access type="discover">
            <machine>
              <world />
            </machine>
          </access>
        </rightsMetadata>
      </objectType>
      EOXML
      RestClient.stub!(:get).and_return(rights)
      
      h = RightsAuth.fetch_and_build('bd186zk8210')
      r = RightsAuth.new(h)
      r.readable?.should be_false
    end
    
  end
  
  describe "#allowed_read_agent?" do
    it "returns true if the passed in user is an allowed read agent" do
      rights =<<-EOXML
      <objectType>
        <rightsMetadata>
          <access type="read">
            <machine>
              <agent>app-name</agent>
            </machine>
          </access>
        </rightsMetadata>
      </objectType>
      EOXML
      RestClient.stub!(:get).and_return(rights)
      
      h = RightsAuth.fetch_and_build('bd186zk8210')
      r = RightsAuth.new(h)
      r.allowed_read_agent?('app-name').should be
    end
    
    it "handles more than one agent" do
      rights =<<-EOXML
      <objectType>
        <rightsMetadata>
          <access type="read">
            <machine>
              <agent>app-name</agent>
              <agent>app2</agent>
            </machine>
          </access>
        </rightsMetadata>
      </objectType>
      EOXML
      RestClient.stub!(:get).and_return(rights)
      
      h = RightsAuth.fetch_and_build('bd186zk8210')
      r = RightsAuth.new(h)
      r.allowed_read_agent?('app2').should be
    end
    
    it "returns false if the passed in user is NOT an allowed read agent" do
      rights =<<-EOXML
      <objectType>
        <rightsMetadata>
          <access type="read">
            <machine>
              <agent>app-name</agent>
            </machine>
          </access>
        </rightsMetadata>
      </objectType>
      EOXML
      RestClient.stub!(:get).and_return(rights)
      h = RightsAuth.fetch_and_build('bd186zk8210')
      r = RightsAuth.new(h)
      r.allowed_read_agent?('another-app-name').should_not be
    end
    
    it "returns false if there is no read agent in rightsMetadata" do
      rights =<<-EOXML
      <objectType>
        <rightsMetadata>
          <access type="read">
            <machine>
              <world />
            </machine>
          </access>
        </rightsMetadata>
      </objectType>
      EOXML
      RestClient.stub!(:get).and_return(rights)
      
      h = RightsAuth.fetch_and_build('bd186zk8210')
      r = RightsAuth.new(h)
      r.allowed_read_agent?('another-app-name').should_not be
    end
    
  end
  
  describe "error handling" do
    
    it "returns nil if it cannot find RightsMetadata" do
      RightsAuth.find('druid:does-not-exist').should be_nil
    end
    
  end
  
  describe "#find" do
    it "should try to grab internal hash from local cache before calling rightsMD service" do
      h = {:stanford_only => true}
      RightsAuth.should_receive(:fetch_from_cache_or_service).and_return h
      
      r = RightsAuth.find('blah')
      r.should be_stanford_only
    end
    
  end
  
end