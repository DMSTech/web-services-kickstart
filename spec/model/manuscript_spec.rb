require File.dirname(__FILE__) + '/../../service/model/manuscript.rb'
require 'json'

describe Manuscript, "#to_json" do
  it "should provide json representation of the manuscript" do
    manuscript = Manuscript.new(1, "http://dmstech.stanford.edu/manuscript/1")
    
    json = JSON.parse(manuscript.to_json)
    json["manuscript"].should == "http://dmstech.stanford.edu/manuscript/1"
    json["manifest"].should == "http://dmstech.stanford.edu/manuscript/1/manifest"
    json["normal_sequence"].should == "http://dmstech.stanford.edu/manuscript/1/normal_sequence"
    json["image_collection"].should == "http://dmstech.stanford.edu/manuscript/1/image_collection"
    json["metadata"].should == "http://dmstech.stanford.edu/manuscript/1/metadata"    
  end
end