require 'djatoka'
require 'nokogiri'
require 'helpers/cacheable'

class DjatokaMetadata
  
  extend Cacheable
  
  THUMBNAIL_EDGE = 240 # 240-pixel long edge dimension
  SQUARE_EDGE    = 100
  
  PRECAST_SIZES = %w(full xlarge large medium small)
  AVAILABLE_MIME_TYPES = %w(image/jpeg image/png image/gif image/bmp)

  # instance variables
  attr_reader :metadata, :level_dimensions

  # constructor
  def initialize(md, stacks_file_path)
    @metadata = md
    @level_dimensions = get_level_dimensions
    @stacks_file_path = stacks_file_path
  end

  # returns the minimum level
  def min_level
    Integer(0)
  end

  # returns the maximum level
  def max_level
    Integer(@metadata[:max_levels])
  end

  # returns the maximum width
  def max_width
    Integer(@metadata[:max_width])
  end

  # returns the maximum height
  def max_height
    Integer(@metadata[:max_height])
  end

  # returns the maximum number of levels
  def max_levels
    Integer(@metadata[:max_levels])
  end

  # returns the level based on the given size category
  def get_level_by_size(size)
    level = max_level - 2   # default to maximum number of levels - 2
    if( size.eql? 'full' )
      level = max_level
    elsif( size.eql? 'xlarge' )
      level = max_level - 1
    elsif( size.eql? 'large' )
      level = max_level - 2
    elsif( size.eql? 'medium' )
      level = max_level - 3
    elsif( size.eql? 'small' )
      level = max_level - 4
    elsif( size.eql? 'thumb' )
      level = get_level_for_long_edge_dimension(THUMBNAIL_EDGE)
    elsif( size.eql? 'square' )
      level = get_level_for_long_edge_dimension(SQUARE_EDGE)
    end
    level
  end

  # returns the scale based on the given size category
  def get_scale_by_size(size)
    scale = nil
    if( size.eql? 'thumb' )
      scale = THUMBNAIL_EDGE.to_s        
    elsif( size.eql? 'square' )
      scale = SQUARE_EDGE.to_s        # 100-pixel long edge dimension
    end
    scale
  end

  # returns the region for the given size category
  def get_region_by_size(size)
    region = nil
    if( size.eql? 'square' )
      region = get_centered_square_region(SQUARE_EDGE)
    end
    region
  end
  
  # Builds an xml document containing the sizes available for this image
  # @return [String] xml containing sizes and formats
  def to_available_size_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.image('xmlns:xlink' => 'http://www.w3.org/1999/xlink', 'xmlns' => 'http://stacks.stanford.edu/image') {
        available_sizes.each do |sz|
          lvl = get_level_by_size(sz).to_s
          xml.size(:id => sz, :width => @level_dimensions[lvl][:width], :height => @level_dimensions[lvl][:height],
                   "xlink:href" => xlink_href_value(sz))
        end
        td = thumb_dimensions
        xml.size(:id => 'thumb', :width => td[:width], :height => td[:height], "xlink:href" => xlink_href_value('thumb'))
        xml.size(:id => 'square', :width => SQUARE_EDGE.to_s, :height => SQUARE_EDGE.to_s, "xlink:href" => xlink_href_value('square'))
        xml.formats {
          AVAILABLE_MIME_TYPES.each {|mt| xml.format("mime-type" => mt)}
        }
      }
    end
    builder.to_xml
  end
  
  def xlink_href_value(size)
    "" << DigitalStacks::STACKS_URL << "/image/" << DigitalStacks.id_from_stacks_file_path(@stacks_file_path) <<
            "/" << DigitalStacks.base_filename_from_stacks_file_path(@stacks_file_path) << "_" << size
  end
  
  # Assembles a Hash containing the sizes available for this image
  # @return [Hash] A Hash suitable for serializing as json
  def to_available_size_hash
    sizes = available_sizes.map do |sz|
      lvl = get_level_by_size(sz).to_s
      {"id" => sz, "width" => @level_dimensions[lvl][:width], "height" => @level_dimensions[lvl][:height], "xlink:href" => xlink_href_value(sz)}
    end
    formats = AVAILABLE_MIME_TYPES.map {|mt| {"mime-type" => mt}}
    { "image" => {
            "size" => sizes,
            "formats" => {
              "format" => formats
            }
       }
    }
  end
  
  # Calculates the height and width of thumbnail version of this image
  # @return [Hash] Returns a Hash with :width and :height as keys
  def thumb_dimensions
    if(landscape?)
      thumb_height = max_height * THUMBNAIL_EDGE / max_width
      return {:width => THUMBNAIL_EDGE, :height => thumb_height}
    else
      thumb_width = max_width * THUMBNAIL_EDGE / max_height
      return {:width => thumb_width, :height => THUMBNAIL_EDGE}
    end
  end
  
  # Determines the next highest Djatoka level for a given zoom percentage, and the scaling factor from that level
  #   to provide the desired zoom
  # @param [Integer, String, Float] zoom The desired zoom percentage between 1 and 100, relative to full image
  # @return [Array<Integer, Float>] The first element of the Array is the next highest Djatoka level for the given zoom,
  #   the second item is the scaling factor from this level to reach the equivalent full size zoom 
  def zoom_level_and_scale(zoom)
    zm = zoom.to_f
    current_zoom = 100.0
    max_level.downto(0) do |level|
      return [ 0,  zm / current_zoom ] if level == 0
      
      next_zoom = current_zoom / 2  
      if(current_zoom >= zm && zm > next_zoom)
        return [level, zm / current_zoom]
      else
        current_zoom = next_zoom
      end
    end
  end
  
  # Takes a zoom level and a region relative to that zoom level and scales the coordinates to x,y values in the full-size image space.
  # @param [Integer, String] zoom The desired zoom percentage between 1 and 100, relative to full image.  The percentage must match 
  #   one of the Djatoka levels for this image
  # @param [String] region Coordinates of a region within the dimensions of the zoom level. Format: x,y,w,h
  # @return [Array<String, Integer>] First element is a String with translated region.  The x and y values are scaled to the full-size image.
  #   Format: scaled-y,scaled-x,h,w.  Second element is the Djatoka level that corresponds to the zoom level.
  def full_size_region_from_zoom(zoom, region)
    current_level, scale = zoom_level_and_scale(zoom)
    unless(scale == 1.0)
      raise ArgumentError.new("Zoom level does not match existing Djatoka levels for this image")
    end
    
    full_size_region_from_level(current_level, region)
  end
  
  # Takes a pre-cast image size and a region within that pre-cast size and scales the coordinates to x,y values in the full-size image space.
  # @param [String] size The desired pre-cast image size
  # @param [String] region Coordinates of a region within the dimensions of pre-cast image. Format: x,y,w,h
  # @return [Array<String, Integer>] First element is a String with translated region.  The x and y values are scaled to the full-size image.
  #   Format: scaled-y,scaled-x,h,w.  Second element is the Djatoka level that corresponds to the pre-cast image size.
  def full_size_region_from_precast_size(size, region)
    current_level = get_level_by_size(size)
    full_size_region_from_level(current_level, region)
  end
 
  def DjatokaMetadata.find(stacks_file_path)
    # return the image metadata
    md = self.fetch_from_cache_or_service(stacks_file_path) do 
      resolver =  Djatoka::Resolver.new(ImageService::DJATOKA_URL)
      dj_md = resolver.metadata(stacks_file_path).perform
      md = { 
        :max_width => dj_md.width,
        :max_height => dj_md.height,
        :max_levels => dj_md.levels 
      }
    end
    DjatokaMetadata.new(md, stacks_file_path)
  end
  
  def DjatokaMetadata.old_find(stacks_file_path)
    resolver =  Djatoka::Resolver.new(ImageService::DJATOKA_URL)
    dj_md = resolver.metadata(stacks_file_path).perform
    md = { 
      :max_width => dj_md.width,
      :max_height => dj_md.height,
      :max_levels => dj_md.levels 
    }

    DjatokaMetadata.new(md, stacks_file_path)
  end
  
  # returns the djatoka square region from the center of the given dimensions
  def get_centered_square_region(scale)
    max_long_edge = get_long_edge_dimension(max_width,max_height)
    max_short_edge = get_short_edge_dimension(max_width,max_height)
    nearest_upper_level = get_nearest_upper_level(scale)
    offset = (max_long_edge - max_short_edge) / 2
    if( portrait? )
      level_short_edge = @level_dimensions["#{nearest_upper_level}"][:width]
      "#{offset},0,#{level_short_edge},#{level_short_edge}" 
    else
      level_short_edge = @level_dimensions["#{nearest_upper_level}"][:height]
      "0,#{offset},#{level_short_edge},#{level_short_edge}" 
    end
  end

  private
  
  # Determine list of available sizes by looking at all of the availale Djatoka levels
  # @return [Array<String>] An array of available sizes for this image
  def available_sizes
    PRECAST_SIZES.select {|s| get_level_by_size(s) >= 0}
  end

  # returns a map of width and height dimensions corresponding to each level
  def get_level_dimensions
    map = Hash.new
    width = max_width
    height = max_height
    max_level.downto(min_level) { |level|
      # map["#{level}"] = [width,height]
      dimensions = { :width => width, :height => height }
      map["#{level}"] = dimensions
      width = width >> 1
      height = height >> 1
    }
    map
  end

  # returns true if the given dimensions represent a portrait
  def portrait?
    max_width <= max_height ? true : false
  end

  # returns true if the given dimensions represent a landscape
  def landscape?
    !portrait?
  end

  # returns the long edge dimension of the given width and height
  def get_long_edge_dimension(width,height)
    width > height ? width : height
  end

  # returns the short edge dimension of the given width and height
  def get_short_edge_dimension(width,height)
    width > height ? height : width
  end

  # returns the level for the long edge dimension
  def get_level_for_long_edge_dimension(dimension)
    max_dimension = get_long_edge_dimension(max_width,max_height)
    nearest_level = max_level
    level_dimension = max_dimension
    max_level.downto(min_level) { |level|
      if( dimension <= level_dimension )
        nearest_level = level
      end
      level_dimension = level_dimension >> 1
    }
    nearest_level
  end

  # returns the nearest upper level closest to the given long edge dimension
  def get_nearest_upper_level(dimension)
    max_dimension = get_long_edge_dimension(max_width,max_height)
    nearest_level = max_level
    level_dimension = max_dimension
    max_level.downto(min_level) { |level|
      if( dimension <= level_dimension )
        nearest_level = level
      end
      level_dimension = level_dimension >> 1
    } 
    nearest_level
  end
  
  def full_size_region_from_level(current_level, region)
    unless (region =~ /^(\d+),(\d+),(\d+),(\d+)$/ )
      raise ArgumentError.new( "Invalid region parameter '#{region}' - must be of the format 'X,Y,W,H'" )
    end
    x = $1; y = $2; w = $3; h = $4
    
    scaling_factor =  2 ** (max_level - current_level)
    scaled_x = x.to_i * scaling_factor
    scaled_y = y.to_i * scaling_factor
    
    ["#{scaled_y},#{scaled_x},#{h},#{w}", current_level]
  end

end

