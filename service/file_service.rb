require File.dirname(__FILE__) + '/model/manuscripts'

module WebServicesKickstart
  class FileService < Sinatra::Base

    get '/:name' do
      name = "services.html" if name == nil
      name = File.dirname(__FILE__) + "/static/" + name
      error 404, "Not found" if !File.exists? name
      send_file name, :type => 'text/html'
    end

  end
end