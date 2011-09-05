require 'djatoka'
require 'djatoka/resolver.rb'

module WebServicesKickstart
  class ImageService < Sinatra::Base
    
    attr_accessor :resolver_host, :resolver
    
    def initialize(*args)
      @resolver_host = get_application_setting("-h", "DJATOKA_RESOLVER_HOST", "http://localhost:8080/adore-jatoka/resolver")
      @resolver = Djatoka::Resolver.new(@resolver_host)
    end

    # Dispatcher method
    get '/image/:druid/:filename' do |druid, filename|
#      if filename.include?("_")
#        # size category image service URL
#        filename_parts = filename.split("_")
#        return get_image_by_size(params, filename_parts)
#      end

      send_file File.dirname(__FILE__) + '/samples/Black_square.jpg',  :type => :jpg
    end

    private

    def get_image_by_size(params, filename_parts)
      djatokaLevel = 0
      case params[1]
      when "square"
      when "thumb"
        djatokaLevel = 0
      when "small"
        djatokaLevel = 1
      when "medium"
        djatokaLevel = 2
      when "large"
        djatokaLevel = 3
      when "xlarge"
        djatokaLevel = 4
      when "full"
        # djatokaLevel = 0
      else
        raise "Invalid size #{params[1]}"
      end
      # TODO continue with this method
    end

  end
end