
require 'stacks_base'
require 'rights_auth'

class FileService < StacksBase

  configure :production do
    STORAGE_ROOT = '/stacks'
    RightsAuth::RIGHTS_MD_SERVICE_URL = 'http://purl.stanford.edu'
  end

  configure :test do
    STORAGE_ROOT = '/stacks'
    RightsAuth::RIGHTS_MD_SERVICE_URL = 'http://purl-test.stanford.edu'
  end

  configure :development do
    STORAGE_ROOT = 'spec/fixtures/stacks'
  end
  
  def validate_file_and_parms
    LyberCore::Log.info("Received [Params]: #{params.inspect}")
    
   #is the id valid?
    if(params[:id] =~ /^druid:([a-z]{2})(\d{3})([a-z]{2})(\d{4})$/i)
      @file_path = File.join(STORAGE_ROOT, $1, $2, $3, $4, params[:file_name])
    else
      throw :halt, [400, "Invalid objectId"]
    end

    unless(File.exists?(@file_path))
      throw :halt, [404, "File Not Found"]
    end

    
    #is this object readable?
    unless(rights.readable?)
      throw :halt, [403, "Forbidden"]
    end
  end

  get '/:id/:file_name' do
    validate_file_and_parms
    
    #is this object stanford-only readable??
    if(rights.stanford_only?)
      redirect "/file/auth/#{params[:id]}/#{params[:file_name]}"
    end

    unless(rights.public?)
      throw :halt, [403, "Forbidden"]
    end

    LyberCore::Log.debug("sending file")
    x_send_file @file_path
  end

  get '/auth/:id/:file_name' do
    validate_file_and_parms
    
    # Prevent the /auth path from being a backdoor to <agent> only items
    if(!rights.stanford_only? && !rights.public?)
      throw :halt, [403, "Forbidden"]
    end

    x_send_file @file_path
  end
  
  # Protected app access to the service
  get '/app/:id/:file_name' do
    app_protected!
    validate_file_and_parms

    x_send_file @file_path
  end

end

