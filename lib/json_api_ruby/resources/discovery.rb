module JsonApi
  module Resources
    class Discovery
      def self.resource_for_name(model, options={})
        namespace = options.fetch(:namespace, nil)
        klass = options.fetch(:resource_class, nil)
        parent = options.fetch(:parent_resource, nil)

        if klass.blank?
          # discover it
          klass = resource_class(model.class.to_s.underscore, namespace: namespace, parent: parent)
        end

        Object.const_get(klass)
      rescue NameError
        fail ::JsonApi::ResourceNotFound.new("Could not find resource class `#{klass}'")
      end

      def self.resource_class(model_name, namespace:, parent:)
        if namespace
          klass = [
            namespace.to_s.underscore,
            "#{model_name.to_s.underscore}_resource"
          ].join('/').classify
        else
          klass = resource_path(model_name, parent).join.classify
        end
        klass
      end

      def self.resource_path(model_name, parent)
        current_namespace = parent.class.to_s.underscore.split('/')
        current_namespace.pop
        current_namespace << '/' if current_namespace.present?
        current_namespace << "#{model_name.to_s}_resource"
        current_namespace
      end
    end
  end
end
