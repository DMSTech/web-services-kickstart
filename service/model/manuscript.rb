require 'json'

class Manuscript
  attr_accessor :url
  def initialize(url)
    @url = url
  end

  def to_json(*a)
    @url.to_json(*a)
  end
end