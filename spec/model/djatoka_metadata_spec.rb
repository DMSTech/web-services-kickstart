require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DjatokaMetadata do
  md =  { 
      :max_width => 4800,
      :max_height => 2400,
      :max_levels => 6 
    }
    
  md_small = { :max_width => 400, :max_height => 600, :max_levels => 3 }  
    
  ld = {
        "0"=>{:width=>75, :height=>37}, 
        "1"=>{:width=>150, :height=>75}, 
        "2"=>{:width=>300, :height=>150},   # small
        "3"=>{:width=>600, :height=>300},   # medium
        "4"=>{:width=>1200, :height=>600},  # large
        "5"=>{:width=>2400, :height=>1200}, # xlarge
        "6"=>{:width=>4800, :height=>2400}  # full
    }
    
  describe "initialization" do
    dm = DjatokaMetadata.new(md, 'some/path')
    
    it "stores the metadata request" do
      dm.metadata.should equal md
    end
    
    it "determines the dimensions for each level" do
      dm.level_dimensions.should == ld
    end
    
    it "handles images with less than 4 levels" do
      dm_small = DjatokaMetadata.new(md_small, 'some/path')
      
      dm_small.level_dimensions.should == {
        "0"=>{:width=>50, :height=>75}, 
        "1"=>{:width=>100, :height=>150}, 
        "2"=>{:width=>200, :height=>300},
        "3"=>{:width=>400, :height=>600}
      }
    end
  end
  
  describe "#zoom_level_and_scale" do
    dm = DjatokaMetadata.new(md, 'some/path')
    
    it "returns the next highest djatoka level and scaling factor for a given zoom percentage" do
      level, scale = dm.zoom_level_and_scale(36)
      level.should == 5
      scale.should eql 0.72
    end
    
    it "accepts string, integer, or float for zoom level" do
      level, scale = dm.zoom_level_and_scale("36")
      level.should == 5
      
      level, scale = dm.zoom_level_and_scale("3.125")
      level.should == 1
      scale.should eql 1.0
    end
    
    it "returns an exact level and scale of 1.0 if the desired zoom level matches" do
      level, scale = dm.zoom_level_and_scale(25)
      level.should == 4
      scale.should eql 1.0
      
      level, scale = dm.zoom_level_and_scale(6.25)
      level.should == 2
      scale.should eql 1.0
    end
    
    it "returns a level of 0 if it exhausts all the given levels for an image" do
      level, scale = dm.zoom_level_and_scale(1)
      level.should == 0
      scale.should eql 0.64
    end
  end
    
  describe "#full_size_region_from_zoom" do
    dm = DjatokaMetadata.new(md, 'some/path')
    
    it "calculates level and full-size region from a given zoom and region" do
      dm.full_size_region_from_zoom("25", "0,0,256,256").should == ["0,0,256,256", 4]
      
      dm.full_size_region_from_zoom("25", "0,256,256,256").should == ["1024,0,256,256", 4]
    end
    
    it "rejects zoom percentages that do not have an exact Djatoka level" do
      lambda { dm.full_size_region_from_zoom("30", "0,256,256,256") }.should raise_error(ArgumentError)
    end
    
    it "rejects regions that are improperly formatted" do
      lambda { dm.full_size_region_from_zoom("50", "0,256,256,256,") }.should raise_error(ArgumentError)
    end
  end
  
  describe "#full_size_region_from_precast_size" do
    dm = DjatokaMetadata.new(md, 'some/path')
    
    it "calculates level and full-size region from a given pre-cast size and region" do
      dm.full_size_region_from_precast_size("large", "0,0,256,256").should == ["0,0,256,256", 4]
      
      dm.full_size_region_from_precast_size("xlarge", "0,256,256,256").should == ["512,0,256,256", 5]
    end
        
    it "rejects regions that are improperly formatted" do
      lambda { dm.full_size_region_from_precast_size("small", "0,256,256,256,") }.should raise_error(ArgumentError)
    end
  end

  describe "#thumb_dimensions" do
    it "returns a hash of the scaled image's width and height for a landscape image" do
      dm = DjatokaMetadata.new(md, 'some/path')
      
      dm.thumb_dimensions.should == {:width => 240, :height => 120 }
    end
    
    it "returns a hash of the scaled image's width and height for a portrait image" do
      portrait_md = {
          :max_width => 2400,
          :max_height => 4800,
          :max_levels => 6 
        }
      dm = DjatokaMetadata.new(portrait_md, 'some/path')
      
      dm.thumb_dimensions.should == {:width => 120, :height => 240 }
    end
  end
  
  describe "#get_level_by_size" do
    
    it "determines the requested size based on the existing Djatoka levels" do
        dm = DjatokaMetadata.new(md, 'some/path')
        
        dm.get_level_by_size('full').should   be 6
        dm.get_level_by_size('xlarge').should be 5
        dm.get_level_by_size('small').should  be 2
    end
  end
    
  describe "#to_available_size_xml" do
    it "lists all availble sizes, dimensions, and image formats in xml" do
      dm = DjatokaMetadata.new(md, 'file:///stacks/bb/718/gz/5962/bb718gz5962_10_0001.jp2')
      expected_size_xml =<<-EOXML
      <?xml version="1.0"?>
      <image xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://stacks.stanford.edu/image">
        <size id="full" height="2400" width="4800" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_full" />
        <size id="xlarge" height="1200" width="2400" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_xlarge"  />
        <size id="large" height="600" width="1200" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_large"  />
        <size id="medium" height="300" width="600" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_medium"  />
        <size id="small" height="150" width="300" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_small"  />
        <size id="thumb" height="120" width="240" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_thumb"  />
        <size id="square" height="100" width="100" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_square"  />
        <formats>
          <format mime-type="image/jpeg"/>
          <format mime-type="image/png"/>
          <format mime-type="image/gif"/>
          <format mime-type="image/bmp"/>
        </formats>
      </image>
      EOXML
      EquivalentXml.equivalent?(dm.to_available_size_xml, expected_size_xml).should be
    end
    
    it "creates xml for images with less than 4 levels" do
      dm = DjatokaMetadata.new(md_small, 'file:///stacks/bb/718/gz/5962/bb718gz5962_10_0001.jp2')
      expected_size_xml =<<-EOXML
      <?xml version="1.0"?>
      <image xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://stacks.stanford.edu/image">
        <size id="full" height="600" width="400" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_full" />
        <size id="xlarge" height="300" width="200" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_xlarge"  />
        <size id="large" height="150" width="100" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_large"  />
        <size id="medium" height="75" width="50" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_medium"  />
        <size id="thumb" height="240" width="160" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_thumb"  />
        <size id="square" height="100" width="100" xlink:href="https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_square"  />
        <formats>
          <format mime-type="image/jpeg"/>
          <format mime-type="image/png"/>
          <format mime-type="image/gif"/>
          <format mime-type="image/bmp"/>
        </formats>
      </image>
      EOXML
      EquivalentXml.equivalent?(dm.to_available_size_xml, expected_size_xml).should be
    end
  end
  
  describe "#to_available_size_hash" do
    it "creates a hash with all available sizes, dimensions, and image formats suitable for generating json" do
      # The hash should look like this
      h = {"image"=>{
            "size"=>[
              {"xlink:href"=>"https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_full", "id"=>"full", "height"=>600, "width"=>400}, 
              {"xlink:href"=>"https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_xlarge", "id"=>"xlarge", "height"=>300, "width"=>200},
              {"xlink:href"=>"https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_large", "id"=>"large", "height"=>150, "width"=>100}, 
              {"xlink:href"=>"https://stacks-test.stanford.edu/image/bb718gz5962/bb718gz5962_10_0001_medium", "id"=>"medium", "height"=>75, "width"=>50} 
            ], 
            "formats" => {
              "format"=>[
                {"mime-type"=>"image/jpeg"},
                {"mime-type"=>"image/png"}, 
                {"mime-type"=>"image/gif"}, 
                {"mime-type"=>"image/bmp"}
              ]
            }
          }
        }
      dm = DjatokaMetadata.new(md_small, 'file:///stacks/bb/718/gz/5962/bb718gz5962_10_0001.jp2')
      dm.to_available_size_hash.should == h
    end
  end
end