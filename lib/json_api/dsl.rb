module JSONAPI
  module DSL
    attr :fields
    attr :relationships

    def attribute(attr)
      @fields ||= []
      @fields << attr
      create_accessor_methods(attr)
    end

    def has_one(object, options={})
      add_relationship(object, {cardinality: :one}.merge(options))
    end

    def has_many(object, options={})
      add_relationship(object, {cardinality: :many}.merge(options))
    end

    def add_relationship(object, options)
      @relationships ||= []
      @relationships << {
        name: object
      }.merge(options)
      create_accessor_methods(object)
    end

    private
    def create_accessor_methods(attr)
      define_method(attr) do
        object.public_send(attr)
      end unless method_defined?(attr)

      define_method("#{attr}=") do |value|
        object.public_send("#{attr}=", value)
      end unless method_defined?("#{attr}=")
    end
  end
end
