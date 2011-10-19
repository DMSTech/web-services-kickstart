require 'memcached'
require 'cache'
require 'lyber_core/log'

# Allows a class to cache the retrieval of data from external services.  Mixin to your class with "extend Cacheable", and use
#   Cacheable#fetch_from_cache_or_service within your static find method.
module Cacheable
  
  def client
    cl = Memcached.new('127.0.0.1:11211', :binary_protocol => false)
    Cache.wrap(cl)
  end
  
  def cache
    @@c ||= client
  end
  
  # Tries to grab content from the local cache.  If it's not there, it will attempt to grab the content by
  #   executing the code in the passed in block, store that result in the cache, then return the result.
  # @param [String] cache_id The id of the item you want to grab from the cache
  # @yield Block that will retrieve the content if it is not in the cache.  Usually a call to grab data
  #   from an external service
  # @yieldreturn The retrieved content.  It will be stored in the cache by cache_id
  # @note Any exceptions thrown trying to get or set data to/from the cache will get swallowed and log a warning.
  #   This allows the caller to still retrieve data even though the cache service might be down.  Exceptions thrown
  #   by the block (i.e. the external service is down) must be handled by the caller
  def fetch_from_cache_or_service(cache_id, &block)
    begin
      content = cache.fetch(cache_id) { yield }
    rescue Exception => e
      LyberCore::Log.warn("Fetch from memcache failed for #{cache_id}:\n#{e.class.to_s}\n#{e.to_s}\n" << e.backtrace.join("\n")  )
      content = yield
    end
    
    content
  end  
end