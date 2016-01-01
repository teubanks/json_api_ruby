require_relative 'discovery'
module JSONAPI
  module Resources

    module Base
      def to_hash(options={})
        resource_hash = identifier_hash
        resource_hash['attributes'] = attributes_hash

        self.class.relationships.each do |relationship|
          resource_hash['relationships'] ||= {}
          resource_hash['relationships'][relationship.name] = relationship.serialize(self)
        end

        resource_hash['links'] = links_hash
        resource_hash
      end

      def identifier_hash
        { 'id' =>  self.id, 'type' =>  self.type }
      end

      def links_hash
        { 'self' => JSONAPI.configuration.base_url + self_link_path }
      end

      def self_link_path
        "/#{self.type}/#{self.id}"
      end

      def attributes_hash
        attrs = {}
        self.class.fields.each do |attr|
          attrs[attr.to_s] = send(attr)
        end
        attrs
      end
    end

  end
end
