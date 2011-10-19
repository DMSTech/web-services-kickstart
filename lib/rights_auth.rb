
require 'rest_client'
require 'nokogiri'
require 'helpers/cacheable'

class RightsAuth
  
  extend Cacheable
  
  def initialize(h={})
    @rights = h
  end
  
  def public?
    @rights[:public]
  end
  
  def readable?
    @rights[:readable]
  end
  
  def stanford_only?
    @rights[:stanford_only]
  end
  
  def allowed_read_agent?(agent)
    @rights[:agents] =~ /#{agent}/
  end
  
  def RightsAuth.find(obj_id)
    obj_id =~ /^druid:(.*)$/
    
    cache_id = "RightsAuth-#{$1}"
    rights_hash = self.fetch_from_cache_or_service(cache_id) { self.fetch_and_build($1) }
    r = RightsAuth.new(rights_hash)
    r
  rescue RestClient::Exception => rce
    LyberCore::Log.exception rce
    nil
  end
  
  # Fetch the rightsMetadata xml from the RightsMD service
  # Parse the xml into the internal hash used to express rights
  # @return Hash internal representation of rights after parsing rightsMetadata xml
  def RightsAuth.fetch_and_build(no_ns_druid)
    xml = RestClient.get( RIGHTS_MD_SERVICE_URL  + "/#{no_ns_druid}.xml")
    doc = Nokogiri::XML(xml)
    rights = {}
    
    if(doc.at_xpath("//rightsMetadata/access[@type='read']/machine/world"))
      rights[:public] = true
    else
      rights[:public] = false
    end
    
    if(doc.at_xpath("//rightsMetadata/access[@type='read']"))
      rights[:readable] = true
    else
      rights[:readable] = false
    end
    
    if(doc.at_xpath("//rightsMetadata/access[@type='read']/machine/group[text() = 'stanford']"))
      rights[:stanford_only] = true
    else
      rights[:stanford_only] = false
    end
    
    agents = ''
    doc.xpath("//rightsMetadata/access[@type='read']/machine/agent").each do |node|
      agents << node.content << ';'
    end
    rights[:agents] = agents
    
    rights
  end
    
  def RightsAuth.old_find(obj_id)
    r = RightsAuth.new
    obj_id =~ /^druid:(.*)$/
    r.rights_xml = Nokogiri::XML(RestClient.get(RIGHTS_MD_SERVICE_URL  + "/#{$1}.xml"))
    r
  end
  
end

