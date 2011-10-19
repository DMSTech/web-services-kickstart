require 'yaml'

module DigiStacks
  
  module Auth
    
    def rights
      @rights ||= lambda {
        id = params[:id]
        id = 'druid:' << id unless( /^druid:/ =~ id)
        RightsAuth.find(id)
      }.call
    end
    
    module App
      APP_LOGIN_FILE = File.join(Sinatra::Application.root, 'logins.yml')
      
      def load_logins
        YAML.load_file(APP_LOGIN_FILE) 
      rescue Exception => e
        LyberCore::Log.warn(e.message + "\n" + e.backtrace.join("\n"))
        LyberCore::Log.warn("!!!!! Unable to load app logins file #{APP_LOGIN_FILE}")
        LyberCore::Log.warn("!!!!! Creating an empty hash of logins.  All login attempts will fail.")
        {}
      end
      
      def valid_apps
        @@va ||= load_logins
      end
            
      def app_protected!
        authenticate
        unless authorized?
          throw(:halt, [403, "Not authorized\n"])
        end
      end

      def authenticate
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        unless(@auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials[1] == valid_apps[@auth.username])
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end
            
      def authorized?
        throw(:halt, [404, "Unable to find RightsMetadata for #{params[:id]}\n"]) if(rights.nil?)
        
        # Return false if object is not public and the app is not allowed to read
        rights.public? || rights.allowed_read_agent?(@auth.username)
      end
      
    end
  end
end