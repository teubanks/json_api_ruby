module JsonApi
  module Resources

    class RelationshipMeta
      # The name of this relationship.
      #
      # This name comes from the resource object that defines the
      # relationship. Example:
      #
      #   class ArticleResource < JsonApi::Resource
      #     has_one :author # this is the name of this relationship
      #   end
      attr_reader :name

      attr_reader :cardinality

      attr_reader :explicit_resource_class

      def initialize(name, options)
        @name = name.to_s
        @cardinality = options.fetch(:cardinality)
        @explicit_resource_class = options.fetch(:resource_class, nil)
      end

      def build_resources(options)
        if cardinality == :one
          relationship = ToOneRelationship.new(name, options.merge(explicit_resource_class: explicit_resource_class))
        else
          relationship = ToManyRelationship.new(name, options.merge(explicit_resource_class: explicit_resource_class))
        end
        relationship.build_resources(options)
        relationship
      end
    end

    class Relationship
      # The resource object that "owns" this relationship
      #
      # Example:
      #   class ArticleResource < JsonApi::Resource
      #     has_one :author
      #   end
      #
      # `ArticleResource` is the parent of the author object
      attr_reader :parent
      attr_reader :parent_model

      # Determines whether the `data` attribute should be filled out and
      # included
      attr_reader :included
      attr_reader :name
      attr_reader :explicit_resource_class


      # The resource object that represents this relationship
      attr_reader :resources

      def initialize(name, options)
        @name = name
        @resources = []
        @parent = options.fetch(:parent_resource)
        @parent_model = parent._model
        @included = options.fetch(:included, false)
        @explicit_resource_class = options.fetch(:explicit_resource_class)
      end

      def included?
        included == true
      end

      def to_hash
        return_hash = links
        return_hash.merge!(data) if included?
        return_hash
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
    class ToOneRelationship < Relationship
      def data(options={})
        identifier_hash = resource_object.identifier_hash if resource_object
        {'data' => identifier_hash}
      end

      def build_resources(options)
        return unless included?
        resource_model = parent_model.send(name)
        return if resource_model.blank?

        resource_class = Discovery.resource_for_name(resource_model, options.merge(parent_resource: parent, resource_class: explicit_resource_class))
        @resources << resource_class.new(resource_model)
      end

      def resource_object
        @resources.first
      end
    end

    class ToManyRelationship < Relationship
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
          resource_class = Discovery.resource_for_name(resource_model, options.merge(parent_resource: parent, resource_class: explicit_resource_class))
          @resources << resource_class.new(resource_model)
        end
      end

      def resource_objects
        @resources
      end
    end
  end
end
