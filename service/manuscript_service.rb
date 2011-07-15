require File.dirname(__FILE__) + '/model/manuscripts'

require 'rubygems'
require 'sinatra'
require 'json'
require 'rdf'
require 'rdf/n3'
require 'rdf/ntriples'
require 'rdf/json'

# TODO Fix this to pull the actual manuscript index
manuscripts = Manuscripts.new()
(1..3).each { |i|
  manuscripts.add(i, "http://dmstech.stanford.edu/manuscript/#{i}")
}

# Gets manuscript collection
get '/v1/manuscript' do
  content_type 'application/json'
  manuscripts.to_json
end

# Gets manuscript
get '/v1/manuscript/:id_str' do |id_str|
  id = nil
  begin
    id = Integer(id_str)
  rescue
    error 400, "Invalid manuscript id #{id_str} "
  end
  
  m = manuscripts.find(id)
  
  error 404, "Not found" if m == nil
  
  content_type 'application/json'
  m.to_json
end