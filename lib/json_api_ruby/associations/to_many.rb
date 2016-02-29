module JsonApi
  module Associations
    class ToMany < JsonApi::Association
      def data(options={})
        data = resource_objects.map do |object|
          object.identifier_hash
        end
        {'data' => data}
      end

      # Build the related resources
      def build_resources(options)
        return unless included?

        parent_model.send(name).each do |resource_model|
          resource_class = JsonApi::Resources::Discovery.resource_for_name(resource_model, options.merge(parent_resource: parent, resource_class: explicit_resource_class))
          @resources << resource_class.new(resource_model, options.merge({include: included.next}))
        end
      end

      def resource_objects
        @resources
      end

      def cardinality
        :many
      end
    end
  end
end
