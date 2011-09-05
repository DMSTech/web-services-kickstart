require File.dirname(__FILE__) + '/base.rb'
require 'json'

module Model
  class Manuscript

    attr_accessor :id, :url
    def initialize(id, url)
      @id = id
      @url = url
    end

    def to_json(*a)
      {
        "manuscript" => @url,
        "manifest" => @url + "/manifest",
        "normal_sequence" => @url + "/normal_sequence",
        "image_collection" => @url + "/image_collection",
        "metadata" => @url + "/metadata"
      }.to_json(*a)
    end
  end
end