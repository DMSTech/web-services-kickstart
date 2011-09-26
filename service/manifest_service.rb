require File.dirname(__FILE__) + '/util/util.rb'

require 'net/http'
require 'uri'
require 'cgi'

module WebServicesKickstart
  class ManifestService < Sinatra::Base
    
    # setting up the environment
    env_index = get_application_setting("-e", "SINATRA_ENV", "development")
    data_dir = get_application_setting("-d", "DATA_DIR", File.dirname(__FILE__) + "/samples/n3/")
    joseki_host = get_application_setting("-h", "JOSEKI_HOST", "http://localhost:2020")

    if (!File.exists? data_dir) || (!File.directory? data_dir)
      raise "Data directory is not configured properly"
    end
        
    get '/manifest/test' do
      url = URI.parse('http://localhost:2020')
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.get('/manifest?query=' + CGI::escape('CONSTRUCT {$a $b $c } WHERE {$a $b $c}'))
      }
      
      graph = RDF::Graph.new()
      RDF::Reader.for(:rdfxml).new(res.body.to_s) do |reader|
        reader.each_statement do |statement|
          graph << statement
        end
      end
      
      writer = RDF::Writer.for(:json)
      output = RDF::JSON::Writer.buffer do |writer|
        graph.each_statement do |statement|
          writer << statement
        end
      end

      # TODO try that with sinatra-jsonp
      # content_type 'application/json'
      content_type 'text/plain'
      output
    end

    # image service (with file extension)
    get '/manifest/:id.n3' do |id|
      # TODO check for security flaw - may read system files this way?
      # http://codeidol.com/other/rubyckbk/Files-and-Directories/Checking-to-See-If-a-File-Exists/
      manifest_file_name = data_dir + id + ".n3"
      if (File.exists? manifest_file_name)
        send_file manifest_file_name, :type => :text
      else
        error 404, "Not found"
      end
    end

    # image service (with file extension)
    get '/manifest/:id.json' do |id|
      manifest_file_name = data_dir + id + ".n3"
      if (!File.exists? manifest_file_name)
        error 404, "Not found"
      end

      graph = RDF::Graph.load(manifest_file_name)
      writer = RDF::Writer.for(:json)
      output = RDF::JSON::Writer.buffer do |writer|
        graph.each_statement do |statement|
          writer << statement
        end
      end

      # TODO try that with sinatra-jsonp
      content_type 'application/json'
      output
    end
  end
end