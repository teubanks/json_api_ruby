require_relative 'discovery'
module JSONAPI
  module Resources
    module Base
      def to_hash
        resource_hash = identifier_hash
        resource_hash['attributes'] = attributes_hash

        if self.class.relationships.present?
          resource_hash['relationships'] = relationship_data
        end

        resource_hash['links'] = links_hash

        resource_hash
      end

      def identifier_hash
        { 'id' =>  self.id, 'type' =>  self.type }
      end

      def links_hash
        { 'self' => JSONAPI.configuration.base_url + "/#{self.type}/#{self.id}" }
      end

      def attributes_hash
        attrs = {}
        self.class.fields.each do |attr|
          attrs[attr.to_s] = send(attr)
        end
        attrs
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
        resource_class = Discovery.resource_for_name(options[:name].to_s.singularize, options.merge(parent_resource: self))
        resource_instance = resource_class.new(model)
        resource_instance.identifier_hash
      end
    end
  end
end
