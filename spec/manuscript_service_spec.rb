require 'spec_helper'

describe WebServicesKickstart::ManuscriptService do
  def app
    @app ||= WebServicesKickstart::ManuscriptService
  end

  describe "service" do
    it "should provide a manuscript collection" do
      get '/manuscript'
      last_response.should be_ok
      json = JSON.parse(last_response.body)
      json.should_not == nil
      json["manuscripts"].should_not == nil
      2.times { |i|
        json["manuscripts"][i].should == "http://dmstech.stanford.edu/manuscript/#{i + 1}"
      }
    end

    it "should provide a manuscript" do
      get '/manuscript/2'
      last_response.should be_ok

      json = JSON.parse(last_response.body)

      json["manuscript"].should == "http://dmstech.stanford.edu/manuscript/2"
      json["manifest"].should == "http://dmstech.stanford.edu/manuscript/2/manifest"
      json["normal_sequence"].should == "http://dmstech.stanford.edu/manuscript/2/normal_sequence"
      json["image_collection"].should == "http://dmstech.stanford.edu/manuscript/2/image_collection"
      json["metadata"].should == "http://dmstech.stanford.edu/manuscript/2/metadata"
    end
  end
end