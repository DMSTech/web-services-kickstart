require File.dirname(__FILE__) + '/util/util.rb'

require 'rdf'
require 'rdf/rdfxml'
require 'rdf/n3'
require 'rdf/ntriples'
require 'rdf/json'
require 'xml'
require 'xslt'

module WebServicesKickstart
  class PrototypeService < Sinatra::Base

    # setting up the environment
    env_index = get_application_setting("-e", "SINATRA_ENV", "development")
    data_dir = get_application_setting("-d", "DATA_DIR", File.dirname(__FILE__) + "/samples/foxml/")

    if (!File.exists? data_dir) || (!File.directory? data_dir)
      raise "Data directory is not configured properly"
    end

    # image service (with file extension)
    get '/prototype/:id' do |id|
      # sanity checks
      data_file_name = data_dir + id + ".xml"
      if (! File.exists? data_file_name)
        error 404, "Not found"
      end

      # load the content and then apply the XSLT to it
      xml_doc = XML::Document.file(data_file_name)
      xsl_doc = XML::Document.file(File.dirname(__FILE__) + '/xslt/foxml_to_rdf.xsl')
      stylesheet = XSLT::Stylesheet.new(xsl_doc)
      result = stylesheet.apply(xml_doc)

      # convert the XSLT output into an RDF graph
      graph = RDF::Graph.new()
      RDF::Reader.for(:rdfxml).new(result.to_s) do |reader|
        reader.each_statement do |statement|
          graph << statement
        end
      end

      # now sparkle the result set
      query = SPARQL::Grammar.parse("SELECT * WHERE { ?s ?p ?o}")
      solutions_array = Array.new
      query.execute(graph).each do |solution|
        solution.each_binding do |name, value|
          hash = Hash.new
          hash[name] = value.to_s()

          solutions_array.push(hash)
        end
      end

      content_type 'application/json'
      # content_type 'text/plain'
      JSON::generate(solutions_array)
    end

    def self.new(*)
      super
    end
  end
end