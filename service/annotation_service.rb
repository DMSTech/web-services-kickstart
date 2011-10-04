module WebServicesKickstart
  # Sinatra front-end for the annotation repository
  class AnnotationService < Sinatra::Base

    attr_accessor :repository
    def initialize(repository)
      @repository = repository
    end

    get '/:id' do
      rdf = @repository.get(:id)
      error 404, "Not found" if rdf == nil
      content_type 'text/plain'
      rdf
    end

    post '/save' do
      rdf = params[:rdf]
      error 400, "Missing RDF content" if rdf == nil || rdf == ""
      rdf_uri = @repository.save(rdf)

      content_type 'text/plain'
      rdf_uri
    end

    get '/author/:author_id' do
      annotations = @repository.find_by_author(:author_id)
      content_type 'text/plain'
      annotations.to_n3
    end

    get '/target/:urn' do
      annotations = @repository.find_by_target_urn(:urn)
      content_type 'text/plain'
      annotations.to_n3
    end

    get '/source/:urn' do
      annotations = @repository.find_by_source_urn(:urn)
      content_type 'text/plain'
      annotations.to_n3
    end

    get '/term/:term' do
      annotations = @repository.search(:urn)
      content_type 'text/plain'
      annotations.to_n3
    end

    get '/filter/:sparql' do
      annotations = @repository.filter(:sparql)
      content_type 'text/plain'
      annotations.to_n3
    end

  end
end