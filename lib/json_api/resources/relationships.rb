module JSONAPI
  module Resources

    class Relationships
      attr_reader :name
      attr_reader :parent
      def initialize(name, options)
        @name = name.to_s
      end

      def serialize(options)
        @parent = options.fetch(:parent_resource)
        {}.merge(links).merge(data)
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
