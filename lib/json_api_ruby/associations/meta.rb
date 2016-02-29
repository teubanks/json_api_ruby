module JsonApi
  module Associations
    UnknownCardinalityError = Class.new(StandardError)

    class Meta
      TO_ONE = :one
      TO_MANY = :many
      CARDINALITY = [TO_ONE, TO_MANY]

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

      def initialize(name, resource_class: nil, cardinality:)
        @name = name.to_s
        validate_cardinality(cardinality)
        @cardinality = cardinality
        @explicit_resource_class = resource_class
      end

      def validate_cardinality(cardinality)
        unless(CARDINALITY.include?(cardinality))
          fail UnknownCardinalityError.new
        end
      end

      def build_resources(options)
        if cardinality == TO_ONE
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
