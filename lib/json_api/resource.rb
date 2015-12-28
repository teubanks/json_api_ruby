require_relative 'resources/base'
require_relative 'resources/relationships'
require_relative 'resources/dsl'

module JSONAPI
  class Resource
    include Resources::Base
    include Resources::Relationships
    extend Resources::DSL

    def self.inherited(subclass)
      subclass.send(:id_field, :id)
    end

    # Can be set using `id_field` in the created resource class like so:
    #
    # class ObjectResource < JSONAPI::Resource
    #   id_field :uuid
    # end
    #
    # defaults to :id
    def id
      object.public_send(self.class._id_field)
    end

    # Can be overridden in a subclass
    def type
      _model.class.to_s.underscore.pluralize
    end

    # Makes the underlying object available to subclasses so we can do things
    # like
    #
    #   class PersonResource < JSONAPI::Resource
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

    attr_accessor :_model

    def initialize(model, options={})
      @_model = model
    end
  end
end
