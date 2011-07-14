require File.dirname(__FILE__) + '/manuscript.rb'
require 'json'

# Collection of manuscripts
class Manuscripts
  attr_accessor :manuscripts
  def initialize()
    @manuscripts = Array.new()
  end

  # Adds a new manuscript with the specified URL to the collection of manuscripts
  def add(manuscript_url)
    manuscript = Manuscript.new(manuscript_url)
    @manuscripts.push(manuscript)
  end

  def to_json(*a)
    {
      'manuscripts' => @manuscripts
    }.to_json(*a)
  end
end