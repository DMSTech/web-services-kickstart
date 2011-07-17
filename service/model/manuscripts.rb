require File.dirname(__FILE__) + '/manuscript.rb'
require File.dirname(__FILE__) + '/base.rb'
require 'json'

# Collection of manuscripts
class Manuscripts < Base
  
  attr_accessor :manuscripts
  
  def initialize()
    @manuscripts = Array.new()
  end

  # Adds a new manuscript with the specified URL to the collection of manuscripts
  def add(manuscript_id, manuscript_url)
    manuscript = Manuscript.new(manuscript_id, manuscript_url)
    @manuscripts.push(manuscript)
  end
  
  # Finds manuscript with the specified id
  # @returns nil if the manuscript with the specified id is not found or the manuscript  
  def find(id)
    m = nil
    for manuscript in @manuscripts do
      m = manuscript if manuscript.id == id      
    end
    return m
  end

  def to_json(*a)
    manuscripts = Array.new()
    @manuscripts.each{|m|
      manuscripts.push(m.url)
    }
    
    {
      'manuscripts' => manuscripts
    }.to_json(*a)
  end
end