require 'spec_helper'

describe WebServicesKickstart::PrototypeService do
  
  def app
    @app ||= WebServicesKickstart::PrototypeService
  end

  describe "service" do
    it "should provide JSON content" do
      get '/prototype/bd017cy0897'
      last_response.should be_ok
    end

    it "should provide JSON for the specified FOXML file" do
      get '/prototype/bd017cy0897'

      attributes = JSON.parse(last_response.body)[0]["s"] # bd017cy0897
      attributes.should_not == nil
    end
  end

end