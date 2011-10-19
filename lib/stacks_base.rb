require 'sinatra/base'
require 'sinatra-xsendfile'
require 'digistacks_auth'

class StacksBase < Sinatra::Base
  include Sinatra::Xsendfile
  include DigiStacks::Auth
  include DigiStacks::Auth::App
  
  enable :sessions
  #use Rack::Session::Pool, :expire_after => 60 * 60 * 24 * 365
end