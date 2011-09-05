require 'spec_helper'

require File.dirname(__FILE__) + '/../../service/model/manifest.rb'

manifest = Model::Manifest.new()

describe Model::Manifest do
  it "should provide non-empty json" do
    json = JSON.parse(manifest.to_json)
    json.should_not == nil
    json["http://dms.stanford.edu/ns/Manifest"].should_not == nil
  end
  
  it "should provide non-empty n3" do
    n3 = manifest.to_n3()
    n3.should_not == nil       
  end
end