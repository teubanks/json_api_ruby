module JsonApi
  module Resources
    module DSL
      attr :_id_field
      attr :_use_links
      attr :fields
      attr :relationships

      def attributes(*attrs)
        attrs.each do |attr|
          attribute(attr)
        end
      end

      def attribute(attr)
        @fields ||= []
        @fields << attr
        create_accessor_methods(attr)
      end

      def has_one(object_name, options={})
        add_relationship(object_name, :one, options)
      end

      def has_many(object_name, options={})
        add_relationship(object_name, :many, options)
      end

      def id_field(key)
        @_id_field = key
      end

      def use_links(yesno)
        @_use_links = yesno
      end

      private
      def add_relationship(object_name, cardinality, options)
        @relationships ||= []
        @relationships << RelationshipMeta.new(object_name, options.merge(cardinality: cardinality))
        create_accessor_methods(object_name)
      end

      def create_accessor_methods(attr)
        define_method(attr) do
          object.public_send(attr)
        end unless method_defined?(attr)

        define_method("#{attr}=") do |value|
          object.public_send("#{attr}=", value)
        end unless method_defined?("#{attr}=")
      end
    end
  end
end
