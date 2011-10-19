require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DigitalStacks do

  before(:all) do
    DigitalStacks.const_set('STACKS_DATA_STORE','spec/fixtures/stacks')
  end

  context ".create_pair_tree" do

    it "returns a pair tree path for valid object identifiers" do
      DigitalStacks.create_pair_tree('druid:xx123yy4567').should eql('xx/123/yy/4567')
      DigitalStacks.create_pair_tree('xx123yy4567').should eql('xx/123/yy/4567')
    end

    it "returns nil for invalid object identifiers" do
      DigitalStacks.create_pair_tree('druid:xx123yy456').should eql(nil)
      DigitalStacks.create_pair_tree('xx123yy456').should eql(nil)
      DigitalStacks.create_pair_tree('x1x2x3y4y5').should eql(nil)
    end

  end

  context ".stacks_file_path" do

    it "returns the absolute file path in the digital stacks for valid object identifiers" do
      actual_file_path = DigitalStacks.get_stacks_file_path('druid:bb718gz5962','bb718gz5962_10_0001')
      expected_file_path = File.join(DigitalStacks::STACKS_DATA_STORE,'bb','718','gz','5962','bb718gz5962_10_0001.jp2')
      actual_file_path.should eql(expected_file_path)
    end

    it "returns the absolute file path of a jpeg2000 file in the digital stacks for valid object identifiers" do
      actual_file_path = DigitalStacks.get_stacks_file_path('druid:bb718gz5962','bb718gz5962_10_0001')
      File.extname(actual_file_path).should eql('.jp2')
    end

    it "returns return nil for invalid object identifiers" do
      DigitalStacks.get_stacks_file_path('druid:xx123yy456','bb718gz5962_10_0001').should eql(nil)
      DigitalStacks.get_stacks_file_path('x1x2x3y4y5','bb718gz5962_10_0001').should eql(nil)
    end

  end
  
  # stacks file path looks like 'file:///stacks/bb/718/gz/5962/bb718gz5962_10_0001.jp2'
  context ".filename_from_stacks_filepath" do
    
    it "parses the file name from a stacks_file_path" do
      fp = 'file:///stacks/bb/718/gz/5962/bb718gz5962_10_0001.jp2'
      DigitalStacks.base_filename_from_stacks_file_path(fp).should == 'bb718gz5962_10_0001'
    end
  end
  
  describe ".id_from_stacks_file_path" do
    
    it "parses the id from a stacks_file_path" do
      fp = 'file:///stacks/bb/718/gz/5962/bb718gz5962_10_0001.jp2'
      DigitalStacks.id_from_stacks_file_path(fp).should == 'bb718gz5962'
    end
  end

  context ".exists?" do

    it "returns true if the file exists in the digital stacks" do
      pending
      #DigitalStacks.exists?('druid:bb718gz5962','bb718gz5962_10_0001').should be_true
    end

    it "returns false if the file does not exist in the digital stacks" do
      DigitalStacks.exists?('druid:bb718gz596','bb718gz5962_10_0001').should be_false
    end

  end

end

