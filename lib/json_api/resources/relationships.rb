module JSONAPI
  module Resources
    module Relationships
      def relationship_links
        self.class.relationships.each do |rel|

        end
      end

      def relationship_data
        hash = {}
        self.class.relationships.each do |rel|
          data = _model.send(rel[:name])

          if data.kind_of?(Array)
            data = data.map do |d|
              get_relationship_data(d, rel)
            end
          else
            data = get_relationship_data(data, rel)
          end

          hash[rel[:name].to_s] = { 'data' => data }
        end
        hash
      end

      def get_relationship_data(model, options)
        resource_class = Discovery.resource_for_name(model, options.merge(parent_resource: self))
        resource_instance = resource_class.new(model)
        resource_instance.identifier_hash
      end
    end
  end
end
