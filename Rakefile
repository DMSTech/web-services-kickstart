require 'rubygems'
require 'rake'
require 'echoe'

# For more information about building a gem, please see
# http://railscasts.com/episodes/135-making-a-gem
#
# To build it locally, please call:
#
# 1.  rake manifest <- Create manifest file describing the content to be included into gem
# 2.  rake install  <- Install the gem locally
# 3.a rake release  <- for Ruby Forge projects
# 3.b rake release  <- for Ruby Forge projects

Echoe.new('dmstech-ws-kickstart', '0.0.1') do |p|
  p.description    = "Web Services Kickstart Project"
  p.url            = "http://github.com/DMSTech/web-services-kickstart"
  p.author         = "Open Sky Solutions"
  p.email          = "info@openskysolutions.com"
  p.ignore_pattern = ["tmp/*", "script/*"] # not included into Gem
  p.development_dependencies = [] # Echoe defaults to adding itself as dev dependency
end

# Load require tasks
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }