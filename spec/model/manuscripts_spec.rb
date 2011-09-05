require 'spec_helper'
require File.dirname(__FILE__) + '/../../service/model/manuscript.rb'
require File.dirname(__FILE__) + '/../../service/model/manuscripts.rb'

repo = Model::Manuscripts.new
10.times { |i|
  repo.add(i, "http://www.example.org/manuscript/#{i}")
}

describe Model::Manuscripts, "#add" do
  it "should add manuscripts" do
    repo.manuscripts.size.should == 10
  end
end

describe Model::Manuscripts, "#find" do
  it "should find added manuscripts" do
    10.times {|i|
      m = repo.find(i)
      m.should_not == nil
      m.id.should == i
    }
  end
end

describe Model::Manuscripts, "#to_json" do
  it "should provide json representation of manuscripts" do
    json = JSON.parse(repo.to_json)
    json["manuscripts"].should_not == nil
    10.times { |i|
      json['manuscripts'][i].should == "http://www.example.org/manuscript/#{i}"
    }
  end
end