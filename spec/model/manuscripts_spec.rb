require File.dirname(__FILE__) + '/../../service/model/manuscript.rb'
require File.dirname(__FILE__) + '/../../service/model/manuscripts.rb'
require 'json'

repo = Manuscripts.new
10.times { |i|
  repo.add("http://www.example.org/manuscript/#{i}")
}

describe Manuscripts, "#add" do
  it "should add manuscripts" do
    repo.manuscripts.size.should == 10
  end
end

describe Manuscripts, "#to_json" do
  it "should provide json representation of manuscripts" do
    json = JSON.parse(repo.to_json)    
    json["manuscripts"].should_not == nil
    10.times { |i|
      json['manuscripts'][i].should == "http://www.example.org/manuscript/#{i}"
    }
  end
end