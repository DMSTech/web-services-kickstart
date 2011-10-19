module Repo
  class Repo
    # Saves the annotation provided into the persistent storage
    #
    # * *Args*    :
    #   - +rdf+ -> RDF to be saved
    # * *Returns* :
    #   - URI of the document
    #
    def save(rdf)
      raise "Must be overridden"
    end
    
    # Loads all annotation from the repository
    #
    # * *Args*    :
    # * *Returns* :
    #   - Array of Model::Annotation instances available in the repository
    #
    def get_all()
      raise "Must be overridden"
    end

    # Loads annotation with the specified URI from the repository
    #
    # * *Args*    :
    #   - +uri+ -> URI  of the document to be loaded
    # * *Returns* :
    #   - Model::Annotation instance with the specified id or nil of the document is not found
    #
    def get(uri)
      raise "Must be overridden"
    end

    # Finds all annotations for the specified author
    #
    # * *Args*    :
    #   - +author+ -> URI representing author of an annotation
    # * *Returns* :
    #   - Model::Annotations instance containing all annotations created by the given author
    #
    def find_by_author(author)
      raise "Must be overridden"
    end

    # Finds all annotations for the specified target URN
    #
    # * *Args*    :
    #   - +urn+ -> Target URN to look for
    # * *Returns* :
    #   - Model::Annotations instance containing all annotations with the specified URN
    #
    def find_by_target_urn(urn)
      raise "Must be overridden"
    end

    # Finds all annotations for the specified source URN
    #
    # * *Args*    :
    #   - +urn+ -> Source URN to look for
    # * *Returns* :
    #   - Model::Annotations instance containing all annotations with the specified URN
    #
    def find_by_source_urn(urn)
      raise "Must be overridden"
    end

    # Searches body of anotations, the author and title for the specified term
    #
    # * *Args*    :
    #   - +term+ -> Text to look for
    # * *Returns* :
    #   - All annotations with the specified term
    #
    def search(term)
      raise "Must be overridden"
    end

    # Searches all annotations matching the specified SPARQL query
    #
    # * *Args*    :
    #   - +sparql+ -> SPARQL query to execute
    # * *Returns* :
    #   - The results of the SPARQL query as provided by the underlying SPARQL implementation
    #
    def filter(sparql)
      raise "Must be overridden"
    end
  end
end