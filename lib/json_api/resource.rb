module JSONAPI
  class Resource
    attr_accessor :_model
    def initialize(model, options={})
      @_model = model
      @is_relationship = options.fetch(:is_relationship, false)
    end

    def to_hash
      resource_hash = {
        'id' =>  self.id,
        'type' =>  _model.class.to_s.underscore.pluralize
      }
      resource_hash['attributes'] = attributes_hash unless is_relationship?

      if self.class.relationships.present? && !is_relationship?
        resource_hash['relationships'] = relationships_hash
      end

      resource_hash
    end

    def is_relationship?
      @is_relationship == true
    end

    def object
      _model
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
        data = _model.send(rel[:name])
        if data.kind_of?(Array)
          data = data.map do |d|
            get_relationship_data(d, rel)
          end
        else
          data = get_relationship_data(data, rel)
        end
        hash[rel[:name].to_s] = {
          'data' => data
        }
      end
      hash
    end

    def get_relationship_data(model, options)
      resource_class = discover_resource(options[:name], options)
      resource_instance = resource_class.new(model, options.merge({is_relationship: true}))
      resource_instance.to_hash
    end

    def discover_resource(resource_name, options={})
      klass = options.fetch(:class_name, nil)
      if klass
        Object.const_get(klass)
      else
        Object.const_get("#{resource_name.to_s.classify}Resource")
      end
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
          object.public_send(attr)
        end unless method_defined?(attr)

        define_method("#{attr}=") do |value|
          object.public_send("#{attr}=", value)
        end unless method_defined?("#{attr}=")
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

    # Define attribute id so it can be set / retrieved
    # Maps to a method/attribute on the model called :id or uses a method
    # within the resource class itself. Allows for overridden id attribute like so:
    #
    #   def id
    #     object.uuid # perhaps?
    #   end
    attribute :id
  end
end
