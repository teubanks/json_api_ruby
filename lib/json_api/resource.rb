module JSONAPI
  class Resource
    attr_accessor :_model
    def initialize(model, options={})
      @_model = model
    end

    def to_hash
      resource_hash = {
        'id' =>  @_model.id,
        'type' =>  @_model.class.to_s.underscore.pluralize,
        'attributes' =>  attributes_hash
      }

      if self.class.relationships.present?
        resource_hash['relationships'] = relationships_hash
      end
      resource_hash
    end

    def object
      @_model
    end

    def attributes_hash
      attrs = {}
      self.class.fields.each do |attr|
        attrs[attr.to_s] = send(attr)
      end
      attrs
    end

    def relationships_hash
      hash = {}
      self.class.relationships.each do |rel|
        hash[rel[:name].to_s] = {}
      end
      hash
    end

    class << self
      attr :fields
      attr :relationships

      def attribute(attr)
        @fields ||= []
        @fields << attr
        create_accessor_methods(attr)
      end

      def create_accessor_methods(attr)
        define_method(attr) do
          object.send(attr)
        end unless method_defined?(attr)
      end

      def has_one(object, options={})
        add_relationship(object, {cardinality: :one}.merge(options))
      end

      def has_many(object, options={})
        add_relationship(object, {cardinality: :many}.merge(options))
      end

      def add_relationship(object, options)
        @relationships ||= []
        @relationships << {
          name: object
        }.merge(options)
        create_accessor_methods(object)
      end
    end
  end
end
