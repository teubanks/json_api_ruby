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
      @meta = options.fetch('meta', Hash.new).stringify_keys
      @object   = object
      @includes = options.fetch('include', [])
      resource_name = "#{@object.class.to_s.underscore}_resource".classify
      @klass_name = options.fetch('class_name', resource_name)
    end

    def to_hash
      resource_klass = Resources::Discovery.resource_for_name(@object, resource_class: @klass_name)
      resource       = resource_klass.new(@object)
      serialized     = { 'data' => resource.to_hash(include: @includes) }
      relationships  = serialized['data'].fetch('relationships', Array.new)
      included_data  = assemble_included_data(@object, resource, relationships)
      serialized['included'] = included_data.values.flatten
      serialized['meta'] = @meta if @meta.present?
      serialized
    end

    def assemble_included_data(model, resource, relationships)
      relationships.each_with_object({}) do |(relationship_name, _), hsh|
        hsh[relationship_name] ||= []

        # next if resource['relationships'].blank?
        # next unless @included.include? relationship_name
        #
        # if !model.respond_to?(relationship_name)
        #   raise InvalidRelationshipError.new("Relationship `#{relationship_name}' not found on class `#{model.class.to_s}'")
        # end

        Array(resource['relationships'][relationship_name]['data']).map {|rd| rd['id']}
      end
    end
  end

  class CollectionSerializer < Serializer
    def initialize(object, options = {})
      super
      @meta = options.fetch :meta, nil
      @klass_name = options.fetch(:class_name, @object.first.class)
    end

    def to_hash
      return {data: []} if @object.empty?

      resource_klass = JsonApi.resolve_resource_name @klass_name
      serialized     = { :data => [] }
      relationships  = resource_klass.relationships
      @object.each_with_index do |model, index|
        resource = resource_klass.new model
        serialized[:data] << resource.to_hash
        included_data = assemble_included_data model, serialized[:data][index],
          relationships
        included_data.each_value do |data|
          serialized[:included] ||= []
          Array.wrap(data).each do |new_data|
            next if serialized[:included].include? new_data
            serialized[:included] << new_data
          end
        end
      end

      serialized[:meta] = @meta if @meta

      serialized
    end
  end
end

