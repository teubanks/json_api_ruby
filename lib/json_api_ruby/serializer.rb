module JsonApi
  extend self

  def serialize_errors(*errors)
    resource_hashes = errors.flatten.map do |error|
      ErrorResource.new(error).to_hash
    end
    { errors: resource_hashes }
  end

  def serialize(object, options = {})
    options.stringify_keys!
    # assume it's a collection
    if !object.nil? && object.respond_to?(:to_a)
      serializer = CollectionSerializer.new(object, options)
    else
      serializer = ObjectSerializer.new(object, options)
    end
    serializer.to_hash
  end

  class Serializer
    attr_reader :object

    def initialize(object, options)
      @meta           = options.fetch('meta', Hash.new).stringify_keys
      @object         = object
      @includes       = options.fetch('include', Includes.new)
      @resource_class = options.fetch('resource_class', nil)
    end

    def resource(object)
      resource_name  = "#{object.class.to_s.underscore}_resource".classify
      klass_name     = @resource_class || resource_name
      resource_klass = Resources::Discovery.resource_for_name(object, resource_class: klass_name)
      resource_klass.new(object, include: Includes.parse_includes(@includes))
    end

    def assemble_included_data(included_resources)
      included_resources.map(&:to_hash)
    end

    def find_included_resources(object_resource)
      included_resources = object_resource.relationships.select {|rel| rel.included?}.flat_map {|rel| rel.resources }
      included_resources += included_resources.flat_map {|res| find_included_resources(res) }
      included_resources.flatten
      unique_identifiers!(included_resources)
    end

    def unique_identifiers!(resources)
      resources.uniq! { |rel| rel.id + rel.type }
      resources
    end
  end

  class ObjectSerializer < Serializer
    def to_hash
      included_resources = []
      if @object.nil?
        serialized = { 'data' => nil }
      else
        object_resource = resource(@object)
        serialized = { 'data' => object_resource.to_hash }
        included_resources += find_included_resources(object_resource)
      end

      serialized['included'] = assemble_included_data(included_resources) if included_resources.present?
      serialized['meta'] = @meta if @meta.present?

      serialized
    end
  end

  class CollectionSerializer < Serializer
    def to_hash
      serialized = {}
      included_resources = []

      data_array = Array(@object).map do |object|
        object_resource = resource(object)
        included_resources += find_included_resources(object_resource)
        unique_identifiers!(included_resources)
        object_resource.to_hash
      end

      serialized['data'] = data_array
      serialized['included'] = assemble_included_data(included_resources) if included_resources.present?
      serialized['meta'] = @meta if @meta.present?

      serialized
    end
  end
end
