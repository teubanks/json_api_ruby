module JsonApi
  class Association
    # The resource object that "owns" this relationship
    #
    # Example:
    #   class ArticleResource < JsonApi::Resource
    #     has_one :author
    #   end
    #
    # `ArticleResource` is the parent of the author object
    attr_reader :parent
    attr_reader :parent_model

    # Determines whether the `data` attribute should be filled out and
    # included
    attr_reader :included
    attr_reader :name
    attr_reader :explicit_resource_class


    # The resource object that represents this relationship
    attr_reader :resources

    def initialize(name, options)
      @name = name
      @resources = []
      @parent = options.fetch(:parent_resource)
      @parent_model = parent._model
      @included = options.fetch(:included, JsonApi::Includes.new)
      @explicit_resource_class = options.fetch(:explicit_resource_class)
    end

    def included?
      included.has_name?(@name)
    end

    def to_hash
      return_hash = {}
      return_hash.merge!(relationship_links) if JsonApi.configuration.use_links
      return_hash.merge!(data) if included?
      return_hash
    end

    def relationship_links
      {
        'links' => {
          'self' => JsonApi.configuration.base_url + parent.self_link_path + "/relationships/#{name}",
          'related' => JsonApi.configuration.base_url + parent.self_link_path + "/#{name}"
        }
      }
    end
  end
end

require_relative 'associations/meta'
require_relative 'associations/to_one'
require_relative 'associations/to_many'

