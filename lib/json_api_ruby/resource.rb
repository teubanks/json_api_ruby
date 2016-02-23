require_relative 'resources/base'
require_relative 'resources/relationships'
require_relative 'resources/dsl'

module JsonApi
  class Resource
    include Resources::Base
    extend Resources::DSL

    def self.inherited(subclass)
      subclass.id_field(@_id_field || :id)
      subclass.use_links(@_use_links || JsonApi.configuration.use_links)
    end

    # Can be set using `id_field` in the created resource class like so:
    #
    #   class ObjectResource < JsonApi::Resource
    #     id_field :uuid
    #   end
    #
    # defaults to :id
    def id
      object.public_send(self.class._id_field).to_s
    end

    # Can be overridden in a subclass
    def type
      _model.class.to_s.underscore.pluralize
    end

    def use_links
      self.class._use_links
    end

    # Makes the underlying object available to subclasses so we can do things
    # like
    #
    #   class PersonResource < JsonApi::Resource
    #     attribute :email
    #     attribute :full_name
    #
    #     def full_name
    #       "#{object.first_name} #{object.last_name}"
    #     end
    #   end
    def object
      _model
    end

    # The model that is used to fill out the data and attributes objects
    attr_accessor :_model

    # Includes can be passed in from a request
    # See:
    #   http://jsonapi.org/format/#fetching-includes
    attr_reader :includes

    def initialize(model, options={})
      options.stringify_keys!
      @_model = model
      @includes = Array.wrap(options.fetch('include', [])).map(&:to_s)
      build_object_graph # base module method
    end
  end
end
