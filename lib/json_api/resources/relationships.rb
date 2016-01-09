module JsonApi
  module Resources

    class Relationships
      # The name of this relationship.
      #   This name comes from the resource object that defines the
      #   relationship. Example:
      #     class ArticleResource < JsonApi::Resource
      #       has_one :author # this is the name of this relationship
      #     end
      attr_reader :name

      # The resource object that "owns" this relationship
      #
      # Example:
      #   class ArticleResource < JsonApi::Resource
      #     has_one :author
      #   end
      #
      # `ArticleResource` is the parent of the author object
      attr_reader :parent

      # Determines whether the `data` attribute should be filled out and
      # included
      attr_reader :included

      # The resource object that represents this relationship
      attr_reader :resource

      attr_reader :parent_model

      def initialize(name, options)
        @name = name.to_s
        @resources = []
      end

      def to_hash
        return_hash = links
        return_hash.merge!(data) if included?
        return_hash
      end

      def build_resources(options)
        @parent = options.fetch(:parent_resource)
        @parent_model = parent._model
        @included = options.fetch(:included, false)
      end

      def included?
        included == true
      end

      def links
        {
          'links' => {
            'self' => JsonApi.configuration.base_url + parent.self_link_path + "/relationships/#{name}",
            'related' => JsonApi.configuration.base_url + parent.self_link_path + "/#{name}"
          }
        }
      end
    end

    # convenience classes
    class ToOneRelationship < Relationships
      def data(options={})
        {'data' => resource_object.identifier_hash}
      end

      def build_resources(options)
        super
        return unless included?
        resource_model = parent_model.send(name)
        resource_class = Discovery.resource_for_name(resource_model, options.merge(parent_resource: parent))
        @resources << resource_class.new(resource_model)
      end

      def resource_object
        @resources.first
      end
    end

    class ToManyRelationship < Relationships
      def data(options={})
        data = resource_objects.map do |object|
          object.identifier_hash
        end
        {'data' => data}
      end

      def build_resources(options)
        super
        return unless included?
        parent_model.send(name).each do |resource_model|
          resource_class = Discovery.resource_for_name(resource_model, options.merge(parent_resource: parent))
          @resources << resource_class.new(resource_model)
        end
      end

      def resource_objects
        @resources
      end
    end
  end
end
