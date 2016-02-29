module JsonApi
  module Associations
    class Meta
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
          relationship = ToOne.new(name, options.merge(explicit_resource_class: explicit_resource_class))
        else
          relationship = ToMany.new(name, options.merge(explicit_resource_class: explicit_resource_class))
        end
        relationship.build_resources(options)
        relationship
      end
    end
  end
end
