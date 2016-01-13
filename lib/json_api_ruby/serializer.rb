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
    if object.present? && object.respond_to?(:to_a)
      serializer = CollectionSerializer.new(object, options)
    else
      serializer = Serializer.new(object, options)
    end
    serializer.to_hash
  end

  class Serializer
    def initialize(object, options)
      @meta           = options.fetch('meta', Hash.new).stringify_keys
      @object         = object
      @includes       = options.fetch('include', [])
      resource_name   = "#{@object.class.to_s.underscore}_resource".classify
      @resource_class = options.fetch('resource_class', resource_name)
    end

    def to_hash
      resource_klass = Resources::Discovery.resource_for_name(@object, resource_class: @resource_class)
      resource       = resource_klass.new(@object, include: @includes)
      serialized     = { 'data' => resource.to_hash }
      relationships  = resource.relationships
      included_data  = assemble_included_data(relationships)

      if included_data.present?
        included_data.uniq! do |inc_data|
          inc_data['id'] + inc_data['type']
        end
        serialized['included'] = included_data
      end

      serialized['meta'] = @meta if @meta.present?
      serialized
    end

    def assemble_included_data(relationships)
      relationships.flat_map do |relationship|
        next if relationship.resources.blank?
        relationship.resources.map(&:to_hash)
      end.compact
    end
  end

  class CollectionSerializer
    def initialize(objects, options = {})
      @meta           = options.fetch('meta', Hash.new).stringify_keys
      @objects        = objects
      @includes       = options.fetch('include', [])
      @resource_class = options.fetch('resource_class', nil)
    end

    def to_hash
      serialized = {}
      included_data = []

      data_array = @objects.map do |object|
        resource_name  = "#{object.class.to_s.underscore}_resource".classify
        klass_name     = @resource_class || resource_name
        resource_klass = Resources::Discovery.resource_for_name(object, resource_class: klass_name)
        resource       = resource_klass.new(object, include: @includes)
        included_data += assemble_included_data(resource.relationships)
        resource.to_hash
      end

      serialized['data'] = data_array

      serialized['meta'] = @meta if @meta

      if included_data.present?
        included_data.uniq! do |inc_data|
          inc_data['id'] + inc_data['type']
        end
        serialized['included'] = included_data
      end

      serialized
    end

    def assemble_included_data(relationships)
      relationships.flat_map do |relationship|
        next if relationship.resources.blank?
        relationship.resources.map(&:to_hash)
      end.compact
    end
  end
end
