# module JsonApi
#   class Serializer
#
#   end
# end

# Path for inclusion of data using the dot method
# Zip through the relationship data and simply serialized the whole object.
# Keep a reference to already included data so we don't re-include or re-query
# for it (possibly future thing?)
module JsonApi
  extend self

  def serialize_errors(*errors)
    resource_klass = resolve_resource_name('ErrorResource')
    resource_hashes = errors.flatten.map do |error|
      resource_klass.new(error).to_hash
    end
    { errors: resource_hashes }
  end

  def serialize(object, options = {})
    options.stringify_keys!
    if object.is_a? Array
      serializer = CollectionSerializer.new(object, options)
    else
      serializer = Serializer.new(object, options)
    end
    serializer.to_hash
  end

  class Serializer
    def initialize(object, options)
      @meta         = options.fetch('meta', Hash.new).stringify_keys
      @object       = object
      @includes     = options.fetch('include', [])
      resource_name = "#{@object.class.to_s.underscore}_resource".classify
      @klass_name   = options.fetch('class_name', resource_name)
    end

    def to_hash
      resource_klass = Resources::Discovery.resource_for_name(@object, resource_class: @klass_name)
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
      @meta     = options.fetch('meta', Hash.new).stringify_keys
      @objects  = objects
      @includes = options.fetch('include', [])
      @klass_name   = options.fetch('class_name', nil)
    end

    def to_hash
      serialized = {}
      included_data = []

      data_array = @objects.map do |object|
        resource_name = "#{object.class.to_s.underscore}_resource".classify
        klass_name   = @klass_name || resource_name
        resource_klass = Resources::Discovery.resource_for_name(object, resource_class: klass_name)
        resource = resource_klass.new(object, include: @includes)
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

