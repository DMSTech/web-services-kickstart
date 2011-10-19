require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "file utilities" do

  context "mime type validation" do

    it "should be initialized with a nil mime type if an empty file format is specified" do
      FileUtilities.get_mime_type('').should be_nil
    end

    it "should default to a nil mime type if a nil file format is specified" do
      FileUtilities.get_mime_type(nil).should be_nil
    end

    it "should be an 'image/jpeg' mime type if a 'jpg' file format is specified" do
      FileUtilities.get_mime_type('jpg').should eql('image/jpeg')
    end

    it "should be an 'image/png' mime type if a 'png' file format is specified" do
      FileUtilities.get_mime_type('png').should eql('image/png')
    end

    it "should be an 'image/gif' mime type if a 'gif' file format is specified" do
      FileUtilities.get_mime_type('gif').should eql('image/gif')
    end

    it "should be an 'image/tiff' mime type if a 'tif' file format is specified" do
      FileUtilities.get_mime_type('tif').should eql('image/tiff')
    end

    it "should be an 'image/bmp' mime type if a 'bmp' file format is specified" do
      FileUtilities.get_mime_type('bmp').should eql('image/bmp')
    end

    it "should be nil mime type for an invalid file format" do
      FileUtilities.get_mime_type('dummy_file_format').should be_nil
    end

  end

end

