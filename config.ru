#require 'sinatra'
#
# see http://stackoverflow.com/questions/5015471/using-sinatra-for-larger-projects-via-multiple-files
#
#require_relative 'service/image_service.rb'
#require_relative 'service/manifest_service.rb'
#
#Dir[root_path("app/**/*.rb")].each do |file|
#    require file
#end
#
#run WebServicesKickstart.new

require File.dirname(__FILE__) + '/config/boot.rb'

run Rack::URLMap.new({
   "/v1/image"         => WebServicesKickstart::ImageService,
   "/v1/manifest"      => WebServicesKickstart::ManifestService,
   "/v1/manuscript"    => WebServicesKickstart::ManuscriptService,
   "/v1/prototype"     => WebServicesKickstart::PrototypeService,
   "/files"            => WebServicesKickstart::FileService,
   "/file"             => FileService,
   "/image"            => ImageService
})