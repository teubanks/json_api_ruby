module JsonApi
  module Associations
    # convenience classes
    class ToOne < JsonApi::Association
      def data(options={})
        identifier_hash = resource_object.identifier_hash if resource_object
        {'data' => identifier_hash}
      end

      def build_resources(options)
        return unless included?
        resource_model = parent_model.send(name)
        return if resource_model.blank?

        resource_class = JsonApi::Resources::Discovery.resource_for_name(resource_model, options.merge(parent_resource: parent, resource_class: explicit_resource_class))
        @resources << resource_class.new(resource_model, options.merge({include: included.next}))
      end

      def resource_object
        @resources.first
      end

      def cardinality
        :one
      end
    end
  end
end
