
require 'stacks_base'
require 'models/image_service_request'
require 'json'
require 'securerandom'
require 'curl'

class ImageService < StacksBase
  
  enable :sessions
  
  configure :production do
    ImageService::DJATOKA_URL = 'http://isis-prod.stanford.edu/adore-djatoka/resolver'
    RightsAuth::RIGHTS_MD_SERVICE_URL = 'http://purl.stanford.edu'
    STORAGE_ROOT = '/stacks'
    DigitalStacks::STACKS_URL = 'https://stacks.stanford.edu'
  end
  
  configure :test do
    ImageService::DJATOKA_URL = 'http://isis-dev.stanford.edu/adore-djatoka/resolver'
    RIGHTS_MD_SERVICE_URL = 'http://purl-test.stanford.edu'
    STORAGE_ROOT = '/stacks'
    DigitalStacks::STACKS_URL = 'https://stacks-test.stanford.edu'
  end
  
  configure :development do
    ImageService::DJATOKA_URL = 'http://isis-dev.stanford.edu/adore-djatoka/resolver'
    RightsAuth::RIGHTS_MD_SERVICE_URL = 'http://purl-test.stanford.edu'
    STORAGE_ROOT = '/stacks'
    DigitalStacks::STACKS_URL = 'https://stacks-test.stanford.edu'
  end
  
  def with_exception_logging(&block)
    @restricted_request = false
    yield
  rescue Exception => e
    LyberCore::Log.exception e
    throw :halt, [500, e.to_s + "\nSee logs for exception detail"]
  end
  
  def thumb_or_square_request?
    params[:filename] =~ /_(thumb|square)\..{3,4}$/ || params[:filename] =~ /_(thumb|square)$/
  end
  
  def available_sizes_request?
    params[:format] =~ /(xml|json)/i
  end
  
  def handle_available_sizes_request
    LyberCore::Log.info("ImageService received [Params]: #{params.inspect}")
    image_request = ImageServiceRequest.new(params, @restricted_request)
    
    md = DjatokaMetadata.find(image_request.stacks_file_path)
    if(params[:format] =~ /xml/)
      available_sizes_content =  md.to_available_size_xml
    else
      # Return json by default
      available_sizes_content = JSON.pretty_generate(md.to_available_size_hash)
    end
    return [200, {'content-type' => Rack::Mime.mime_type('.' << params[:format])}, available_sizes_content]  
  end
  
  def redirect_to_auth_path
    if(params[:format])
        auth_path = "/image/auth/#{params[:id]}/#{params[:filename]}.#{params[:format]}"
    else
        auth_path = "/image/auth/#{params[:id]}/#{params[:filename]}"
    end
    qs = request.query_string
    auth_path << (qs == "" ? "" : "?#{qs}")
    redirect auth_path
  end
    
  # Unauthenticated path
  ['/:id/:filename.:format/?', '/:id/:filename/?'].each do |path|
    get path do
      with_exception_logging do
        if available_sizes_request?
          # can't return from a block, use next
          # http://stackoverflow.com/questions/2325471/using-return-in-a-ruby-block
          next handle_available_sizes_request
        end
        if(rights.stanford_only? && !thumb_or_square_request?)
          if(session[:webauth_user])
            LyberCore::Log.debug("session[:webauth_user]: #{session[:webauth_user]}")
            image_service(params)
          else
            redirect_to_auth_path
          end
          next
        end
        # If stanford only or not public, but is a thumb or square request
        if(rights.stanford_only? && thumb_or_square_request?)
          @restricted_request = true
        elsif(!rights.public?)
          throw(:halt, [403, "Not authorized\n"])
        end
        image_service(params)
      end 
    end
  end
  
  def webauthed?
    user = request.env['WEBAUTH_USER']
    return false if(user.nil? || user.empty?)
    true
  end
  
  # Authenticated path
  ['/auth/:id/:filename.:format/?', '/auth/:id/:filename/?'].each do |path|
    get path do
      with_exception_logging do
        # Set the webauth user into the session so that we don't have to redirect for subsequent requests
        if webauthed?
          LyberCore::Log.debug('request.env[WEBAUTH_USER]: ' << request.env['WEBAUTH_USER'])
          session[:webauth_user] = request.env['WEBAUTH_USER']
        end
        if available_sizes_request?
          # can't return from a block, use next
          # http://stackoverflow.com/questions/2325471/using-return-in-a-ruby-block
          next handle_available_sizes_request
        end
        # Prevent the /auth path from being a backdoor to <agent> only items
        if(!rights.stanford_only? && !rights.public?)
          throw :halt, [403, "Restricted image"]
        end
        with_exception_logging { image_service(params)}
      end
    end
  end
    
  # App path
  ['/app/:id/:filename.:format/?', '/app/:id/:filename/?'].each do |path|
    get path do
      with_exception_logging do
        authenticate
      
        if available_sizes_request?
          # can't return from a block, use next
          # http://stackoverflow.com/questions/2325471/using-return-in-a-ruby-block
          next handle_available_sizes_request
        end
        if( !authorized? && !thumb_or_square_request?)
          throw(:halt, [403, "Not authorized\n"])
        end
      
        image_service(params)
      end
    end
  end


  # core image service
  def image_service(params)
    LyberCore::Log.info("ImageService received [Params]: #{params.inspect}")
    image_request = ImageServiceRequest.new(params, @restricted_request)
        
    # Toggle image delivery behavior based on the supplied 'action' parameter
    action = params[:action]
    url = image_request.url
    LyberCore::Log.debug("image_request.url: #{CGI::unescape(url)}")
    #file_contents = RestClient.get url
    if( action.eql? 'download' )
      send_opts = {:filename => "#{params[:filename]}.#{image_request.format}", :type => "#{image_request.mime_type}", :disposition => "attachment"}
    else
      send_opts = {:type => "#{image_request.mime_type}", :disposition => "inline"}
    end
    path = ''
    curl = Curl::Easy.perform(url)
    File.open(File.join(Sinatra::Application.root, "..", "tmp", "image", SecureRandom.hex(10)), "wb") do |f|
      f << curl.body_str
      path = f.path
    end

    x_send_file path, send_opts
  end

  


end

