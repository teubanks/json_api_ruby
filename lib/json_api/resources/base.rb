require_relative 'discovery'
module JsonApi
  module Resources

    module Base
      def to_hash(options={})
        options.symbolize_keys

        resource_hash = identifier_hash
        resource_hash['attributes'] = attributes_hash
        included_objects = parse_for_includes(options[:include])

        self.class.relationships.each do |relationship|
          included = included_objects.include?(relationship.name)
          resource_hash['relationships'] ||= {}
          resource_hash['relationships'][relationship.name] = relationship.serialize({parent_resource: self, included: included})
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
    end

  end
end
