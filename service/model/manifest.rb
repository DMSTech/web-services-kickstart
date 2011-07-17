require File.dirname(__FILE__) + '/base.rb'
require 'json'

class Manifest < Base
  
  def to_json(*a)
    # FIXME hardcode for now
    {
      "http://dms.stanford.edu/ns/Manifest" => {
        "http://www.openarchives.org/ore/terms/aggregates" => [
          {
            "value" => "http://dms.stanford.edu/ns/ImageCollection",
            "type" => "uri"
          },
          {
            "value" => "http://dms.stanford.edu/ns/NormalSequence",
            "type" => "uri"
          }
        ],
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" => [
          {
            "value" => "http://www.openarchives.org/ore/terms/Aggregation",
            "type" => "uri"
          }
        ]
        },
        "http://dms.stanford.edu/ns/ImageCollection" => {
          "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" => [
            {
              "value" => "http://www.openarchives.org/ore/terms/Aggregation",
              "type" => "uri"
            },
            {
              "value" => "http://www.openarchives.org/ore/terms/List",
              "type" => "uri"
            }
          ]
      },
      "http://dms.stanford.edu/ns/NormalSequence" => {
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" => [
          {
            "value" => "http://www.openarchives.org/ore/terms/Aggregation",
            "type" => "uri"
          },
          {
            "value" => "http://www.openarchives.org/ore/terms/List",
            "type" => "uri"
          }
        ]
      }
    }.to_json(*a)
  end  
end