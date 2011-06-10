require 'rubygems'
require 'exifr'
require 'tempfile'

# Helper class for determining basic JPEG information
class ImageHelper 
  attr_accessor :width, :height, :attributes, :exif_info
  
  # Class constructor that takes Net::HTTP response body and attempts to parse it.
  def initialize(image_source)
    puts "Creating magic file"
    
    tempfile = Tempfile.new('image_helper_magicfile.jpeg')
    
    puts "Created #{tempfile}"
    
    File.open(tempfile.path,'w') do |f|
      f.write image_source
      f.flush
    end
    
    puts "Finished streaming into #{tempfile}. File size is now #{tempfile.size}"
    
    @exif_info = EXIFR::JPEG.new(tempfile.path)
    
    puts "Initialized exif info: #{exif_info}"
    
    @width = @exif_info.width
    @height = @exif_info.height
    
    if @exif_info.exif? then
      @attributes = @exif_info.exif.to_hash
    end
  end
  
  def to_s
    @attributes.to_s
  end
end
