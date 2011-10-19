
require 'models/digital_stacks'
require 'helpers/file_utilities'
require 'djatoka'
require 'set'

# Validates the paramaters from the user request
class ImageServiceRequest

  # constants
  DRUID_REGEX = /^[a-z]{2}\d{3}[a-z]{2}\d{4}$/i
  PUBLIC_REQUEST_PARAMS = %w(id filename format action rotate)
  PRIVILEGED_REQUEST_PARAMS = %w(w h region zoom) # removed level
  VALID_PARAMS = Set.new(PUBLIC_REQUEST_PARAMS | PRIVILEGED_REQUEST_PARAMS)
  VALID_RESTRICTED_REQUEST_PARAMS = Set.new( %w(id filename format))
  SIZE_CATEGORIES = %w(square thumb small medium large xlarge full)
  SIZE_REGEX = /_(#{SIZE_CATEGORIES.join('|')})$/i

  # instance variables with public getter methods and private setter methods 
  attr_reader :id, :filename, :format, :stacks_file_path, :mime_type, :level, :size, :rotation, :scale, :region
  attr_reader :djatoka_region

  # constructor
  # @param [Hash] params Params passed in from the request
  # @param [Boolean] restricted_request True if image is Stanford-only _thumb or _square request, false otherwise
  def initialize(params, restricted_request=false)  
    # ensure all the request parameters are valid
    if( !valid_params?(params) )
      raise ArgumentError.new( "Invalid request parameters" )
    end
            
    @restricted = restricted_request
    if(@restricted && restricted_params?(params))
      raise ArgumentError.new( "Image format is the only valid parameter for a restricted _thumb or _square request")
    end
    
    set_id(params[:id])
    set_filename(params[:filename])
    set_stacks_file_path(@filename)
    
    @resolver =  Djatoka::Resolver.new(ImageService::DJATOKA_URL)
    @djatoka_region = @resolver.region(@stacks_file_path)

    
    set_file_format(params[:format])
    # Short circuit the rest of param validation if this is an available-sizes request
    return if(available_sizes?)
    
    # validate and set each image service request parameter
    set_mime_type(@format)
    set_rotation(params[:rotate])
    
    if( (params.include?("zoom") || params.include?(:zoom)) && 
        !params.include?(:region) && !params.include?('region') )
      build_djatoka_zoom_request(params)
      return
    end
    
    set_size(@filename)
    if(@size && !params.include?(:region) && !params.include?('region') )
      build_pre_cast_size_request
      return
    end
    set_scale(params[:w],params[:h])
    set_region(params)

    # ensure there are no conflicting public and privileged parameters
    # if( conflicting_params? )
    #   raise ArgumentError.new( "Conflicting public and privileged request parameters" )
    # end
  end

  # returns true or false based on whether the given parameter hash contains only valid parameter names
  def valid_params?(params)
    params.keys.all? {|p| VALID_PARAMS.include?(p.to_s)}
  end
  
  # returns true if any param other than VALID_RESTRICTED_REQUEST_PARAMS was passed in
  def restricted_params?(params)
    params.keys.any? {|p| not VALID_RESTRICTED_REQUEST_PARAMS.include?(p.to_s)}
  end

  # returns true or false based on whether there are conflicting public and privileged request parameters
  # TODO you cannot combine a pre-defined size request with zoom, or region or scale
  def conflicting_params?
    is_conflicting = false
    if( !@size.nil? and (!@level.nil? or !@region.nil? or !@scale.nil?) )
      is_conflicting = true
    end
    is_conflicting
  end

  # id setter method
  def set_id(id)
    if( id !~ DRUID_REGEX )
      raise ArgumentError.new( "Invalid object identifier '#{id}'" )
    end
    @id = id
  end

  # filename setter method
  def set_filename(filename)
    @filename = filename
  end

  # stacks file path setter method
  def set_stacks_file_path(filename)
    file_prefix = get_file_prefix(filename)
    stacks_file_path = DigitalStacks.get_stacks_file_path(@id,file_prefix)
    if( stacks_file_path.nil? or !File.extname(stacks_file_path).eql? ".jp2" )
      raise ArgumentError.new( "Invalid filename parameter '#{file_prefix}' - must be a valid jp2 file" )
#    elsif( !DigitalStacks.exists?(@id,file_prefix) )
#      raise ArgumentError.new( "Invalid filename parameter '#{file_prefix}' - does not exist in the digital stacks" )
    end
    @stacks_file_path = !stacks_file_path.nil? ? "file://#{stacks_file_path}" : nil
  end

  # file format setter method, default to jpg
  def set_file_format(format)
    if( !format.nil? and !format.empty? )
      @format = format
    else
      @format = 'jpg'
    end
  end

  # mime type setter method
  def set_mime_type(format)
    if( !format.nil? and !format.empty? )
      @mime_type = FileUtilities.get_mime_type(format)
      if( mime_type.nil? )
        raise ArgumentError.new( "Invalid image format parameter '#{format}' - must be a valid image mime-type" )
      end
       @djatoka_region.format(@mime_type)
    end
  end

  # size setter method
  # It is parsed from the filename and should end with: _SIZE  
  def set_size(filename)
    if( filename =~ SIZE_REGEX)
      @size = $1.downcase
    end
  end
  
  def build_pre_cast_size_request
    md = DjatokaMetadata.find(@stacks_file_path)
    @djatoka_region.level(md.get_level_by_size(@size))
    
    if(@size =~ /thumb/)
      @djatoka_region.scale(DjatokaMetadata::THUMBNAIL_EDGE)
    elsif(@size =~ /square/)
      @djatoka_region.scale(DjatokaMetadata::SQUARE_EDGE).region(md.get_centered_square_region(DjatokaMetadata::SQUARE_EDGE))
    end

  end

  # rotation setter method
  def set_rotation(rotation)
    if( !rotation.nil? and !rotation.empty? )
      rotation_val = Integer(rotation)
      multiple = rotation_val % 90
      if( rotation_val < 0 )
        raise ArgumentError.new( "Invalid rotation parameter '#{rotation}' - must be greater than 0 degrees" )
      elsif( multiple != 0 )
        raise ArgumentError.new( "Invalid rotation parameter '#{rotation}' - must be increments of 90 degrees" )
      end
      @djatoka_region.rotate(rotation)
    end
  end

  # scale setter method
  def set_scale(width,height)
    if( !width.nil? and !width.empty? )
      width_val = Integer(width)
      if( width_val < 0 )
        raise ArgumentError.new( "Invalid width scale parameter '#{width}' - must be greater than 0" )
      end
    end
    if( !height.nil? and !height.empty? )
      height_val = Integer(height)
      if( height_val < 0 )
        raise ArgumentError.new( "Invalid height scale parameter '#{height}' - must be greater than 0" )
      end
    end
    if( !width.nil? and !height.nil? )
      @scale = "#{width},#{height}"
    elsif( !width.nil? )
      @scale = "#{width},0"
    elsif( !height.nil? )
      @scale = "0,#{height}"
    end
    @djatoka_region.scale(@scale)
  end

  # Sets the Djatoka region parameter.  If this is a zoom or pre-cast size request, then the region from the request
  #  params will be scaled to the full-size image.  Otherwise, region is assumed to be from the full-size image
  # @param [Hash] params passed in from the user.  Looks at the following params:
  #   :region Represents the coordinates(x,y) and size(w,h) of a region from the full-size image.  Format: x,y,w,h
  def set_region(params)
    region = params[:region]
    return if(region.nil?)
    unless (region =~ /^(\d+),(\d+),(\d+),(\d+)$/ )
      raise ArgumentError.new( "Invalid region parameter '#{region}' - must be of the format 'X,Y,W,H'" )
    end
    
    if( params.include?("zoom") || params.include?(:zoom) )
      md = DjatokaMetadata.find(@stacks_file_path)
      @region, level = md.full_size_region_from_zoom(params[:zoom], region)
      @djatoka_region.level(level)
    elsif (@size)
      md = DjatokaMetadata.find(@stacks_file_path)
      @region, level = md.full_size_region_from_precast_size(@size, region)
      @djatoka_region.level(level)
    else
      x = $1; y = $2; w = $3; h = $4
      @region = "#{y},#{x},#{h},#{w}"
    end
    
    @djatoka_region.region(@region)
  end

  # returns the prefix of the given filename stripped of its size category (if one exists)
  def get_file_prefix(filename)
    file_prefix = filename.gsub(File.extname(filename),'')
    SIZE_CATEGORIES.each do |size|
      if( file_prefix.match /_#{size}$/i )
        file_prefix.gsub!(/_#{size}$/i,'')
      end
    end
    file_prefix
  end
  
  # returns true if the format is xml or json
  def available_sizes?
    return true if(@format == 'xml' || @format == 'json')
    false
  end

  # return a djatoka-specific url based on the image server request parameters names and values
  def url
    return @djatoka_region.url
  end
  
  def build_djatoka_zoom_request(params)
    raise ArgumentError.new("zoom level must be value between 1 and 100") if(params[:zoom].to_i > 100 || params[:zoom].to_i < 1)
    md = DjatokaMetadata.find(@stacks_file_path)
    
    level, scale = md.zoom_level_and_scale(params[:zoom])
    @djatoka_region.level(level)
    @djatoka_region.scale(scale) unless(scale == 1.0)
  end

end

