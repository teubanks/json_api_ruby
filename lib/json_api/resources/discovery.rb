module JSONAPI
  module Resources
    class Discovery
      def self.resource_for_name(resource_name, options={})
        namespace = options.fetch(:namespace, nil)
        klass = options.fetch(:resource_class, nil)
        parent = options.fetch(:parent_resource, nil)

        klass = resource_class(resource_name, namespace: namespace, parent: parent) if klass.blank?

        Object.const_get(klass)
      rescue NameError
        fail ::JSONAPI::ResourceNotFound.new("Could not find resource class `#{klass}'")
      end

      def self.resource_class(resource_name, namespace:, parent:)
        if namespace
          klass = [
            namespace.to_s.underscore,
            "#{resource_name.to_s.underscore}_resource"
          ].join('/').classify
        else
          klass = resource_path(resource_name, parent).join.classify
        end
        klass
      end

      def self.resource_path(resource_name, parent)
        current_namespace = parent.class.to_s.underscore.split('/')
        current_namespace.pop
        current_namespace << '/' if current_namespace.present?
        current_namespace << "#{resource_name.to_s}_resource"
        current_namespace
      end
    end
  end
end
