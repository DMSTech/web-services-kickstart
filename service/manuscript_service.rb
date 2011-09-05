require File.dirname(__FILE__) + '/model/manuscripts'
  
#require 'rubygems'
#require 'sinatra'
#require 'json'
#require 'rdf'
#require 'rdf/n3'
#require 'rdf/ntriples'
#require 'rdf/json'

module WebServicesKickstart
  class ManuscriptService < Sinatra::Base

    # TODO Fix this to pull the actual manuscript index
    manuscripts = Model::Manuscripts.new()
    (1..3).each { |i|
      manuscripts.add(i, "http://dmstech.stanford.edu/manuscript/#{i}")
    }

    # Gets manuscript collection
    get '/manuscript' do
      content_type 'application/json'
      manuscripts.to_json
    end

    get '/manuscript.txt' do
      content_type 'plain/text'
      manuscripts.to_n3
    end

    # Gets manuscript
    get '/manuscript/:id_str' do |id_str|
      error 400, "Null ids are not allowed" if id_str == nil

      # check for extension
      has_ext = id_str.downcase.index(/\.[a-z]*/) != nil
      ext = "json"

      if has_ext
        splits = id_str.split('.')
        if splits.size() > 2 || splits.size() == 0
          error 400, "Invalid manuscript id #{id_str}"
        end
        if (splits.size() == 1)
          id_str = splits[0]
        else
          id_str = splits[0]
          ext = splits[1]
        end
      end

      id = nil
      begin
        id = Integer(id_str)
      rescue
        error 400, "Invalid manuscript id #{id_str} "
      end

      m = manuscripts.find(id)
      error 404, "Not found" if m == nil

      case ext
      when "txt"
        content_type 'text/plain'
        m.to_json
      when "json"
        content_type 'application/json'
        m.to_json
      when "n3"
        content_type 'application/n3'
        m.to_n3
      end
    end

  end
end