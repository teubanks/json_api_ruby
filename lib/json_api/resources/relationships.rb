module JSONAPI
  module Resources

    class Relationships
      attr_reader :name
      attr_reader :parent
      def initialize(name, options)
        @name = name.to_s
      end

      def serialize(parent)
        @parent = parent
        {}.merge(relationship_links).merge(relationship_data)
      end

      def relationship_links
        {
          'links' => {
            'self' => parent.self_link_path + "/relationships/#{name}",
            'related' => ''
          }
        }
      end

      def relationship_data(options={})
        data = parent.object.send(name)

        if data.kind_of?(Array)
          data = data.map do |d|
            get_relationship_identity(d)
          end
        else
          data = get_relationship_identity(data)
        end

        { 'data' => data }
      end

      def get_relationship_identity(model, options={})
        resource_class = Discovery.resource_for_name(model, options.merge(parent_resource: parent))
        resource_instance = resource_class.new(model)
        resource_instance.identifier_hash
      end
    end

    class ToOneRelationship < Relationships
      def cardinality
        :one
      end
    end

    class ToManyRelationship < Relationships
      def cardinality
        :many
      end
    end

  end
end
