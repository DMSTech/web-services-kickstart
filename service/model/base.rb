require 'rubygems'
require 'json'
require 'rdf'
require 'rdf/n3'
require 'rdf/ntriples'
require 'rdf/json'

module Model
  
  class Base
    def to_n3(*a)
      json = to_json(*a)
      RDF::N3::Writer.buffer do |writer|
        RDF::JSON::Reader.new(json) do |reader|
          reader.each_statement do |statement|
            writer << statement
          end
        end
      end
    end

    def to_json(*a)
      {}.to_json(*a)
    end

  end
end