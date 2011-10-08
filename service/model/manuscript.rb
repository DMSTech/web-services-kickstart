require File.dirname(__FILE__) + '/base.rb'

module Model
  class Manuscript < Model::Base

    attr_accessor :id, :url
    def initialize(id, url)
      @id = id
      @url = url
    end

    def to_json(*a)
      result = {
        "manuscript" => @url,
        "manifest" => @url + "/manifest",
        "normal_sequence" => @url + "/normal_sequence",
        "image_collection" => @url + "/image_collection",
        "metadata" => @url + "/metadata"
      }
      result.to_json(*a)
    end
  end
end