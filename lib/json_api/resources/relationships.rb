module JSONAPI
  module Resources

    class Relationships
      # The name of this relationship.
      #   This name comes from the resource object that defines the
      #   relationship. Example:
      #     class ArticleResource < JSONAPI::Resource
      #       has_one :author # this is the name of this relationship
      #     end
      attr_reader :name

      # The resource object that "owns" this relationship
      #
      # Example:
      #   class ArticleResource < JSONAPI::Resource
      #     has_one :author
      #   end
      #
      # `ArticleResource` is the parent of the author object
      attr_reader :parent

      # Determines whether the `data` attribute should be filled out and
      # included
      attr_reader :included

      def initialize(name, options)
        @name = name.to_s
      end

      def serialize(options)
        @parent = options.fetch(:parent_resource)
        @included = options.fetch(:included, false)
        return_hash = links
        return_hash.merge!(data) if included?
        return_hash
      end

      def included?
        included == true
      end

      def links
        {
          'links' => {
            'self' => JSONAPI.configuration.base_url + parent.self_link_path + "/relationships/#{name}",
            'related' => JSONAPI.configuration.base_url + parent.self_link_path + "/#{name}"
          }
        }
      end

      def data(options={})
        data = parent.object.send(name)

        if data.kind_of?(Array)
          data = data.map do |d|
            identity(d)
          end
        else
          data = identity(data)
        end

        { 'data' => data }
      end

      def identity(model, options={})
        resource_class = Discovery.resource_for_name(model, options.merge(parent_resource: parent))
        resource_instance = resource_class.new(model)
        resource_instance.identifier_hash
      end
    end

    # convenience classes
    ToOneRelationship  = Class.new(Relationships)
    ToManyRelationship = Class.new(Relationships)
  end
end
