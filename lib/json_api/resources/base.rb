require_relative 'discovery'
module JsonApi
  module Resources

    module Base
      attr_reader :relationships
      def to_hash(options={})
        options.symbolize_keys

        resource_hash = identifier_hash
        resource_hash['attributes'] = attributes_hash

        relationships.each do |relationship|
          resource_hash['relationships'] ||= {}
          resource_hash['relationships'][relationship.name] = relationship.to_hash
        end

        resource_hash['links'] = links_hash
        resource_hash
      end

      # Very basic. Eventually this will need to parse things like
      # "article.comments" and "article-comments", so, leaving the method here
      # but only supporting the most basic of things
      def parse_for_includes(includes)
        Array(includes).map {|inc| inc.to_s }
      end

      def identifier_hash
        { 'id' =>  self.id, 'type' =>  self.type }
      end

      def links_hash
        { 'self' => JsonApi.configuration.base_url + self_link_path }
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

      # Builds relationship resource classes
      def build_object_graph
        @relationships ||= []
        Array(self.class.relationships).each do |relationship|
          included = includes.include?(relationship.name)
          relationship.build_resources({parent_resource: self, included: included})
          @relationships << relationship
        end
      end
    end

  end
end
