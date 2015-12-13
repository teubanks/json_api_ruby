module JSONAPI
  class Resource
    extend JSONAPI::DSL

    def self.inherited(subclass)
      subclass.send(:primary_key, :id)
    end

    # Can be set using `primary_key` in the created resource class like so:
    #
    # class ObjectResource < JSONAPI::Resource
    #   primary_key :uuid
    # end
    def id
      object.public_send(self.class._primary_key)
    end

    def type
      _model.class.to_s.underscore.pluralize
    end

    attr_accessor :_model

    def initialize(model, options={})
      @_model = model
      @is_relationship = options.fetch(:is_relationship, false)
    end

    def to_hash
      resource_hash = {
        'id' =>  self.id,
        'type' =>  self.type
      }
      resource_hash['attributes'] = attributes_hash unless is_relationship?

      if self.class.relationships.present? && !is_relationship?
        resource_hash['relationships'] = relationships_hash
      end

      resource_hash
    end

    def is_relationship?
      @is_relationship == true
    end

    def object
      _model
    end

    def attributes_hash
      attrs = {}
      self.class.fields.each do |attr|
        attrs[attr.to_s] = send(attr)
      end
      attrs
    end

    def relationships_hash
      hash = {}
      self.class.relationships.each do |rel|
        data = _model.send(rel[:name])

        if data.kind_of?(Array)
          data = data.map do |d|
            get_relationship_data(d, rel)
          end
        else
          data = get_relationship_data(data, rel)
        end

        hash[rel[:name].to_s] = { 'data' => data }
      end
      hash
    end

    def get_relationship_data(model, options)
      resource_class = discover_resource(options[:name], options)
      resource_instance = resource_class.new(model, options.merge({is_relationship: true}))
      resource_instance.to_hash
    end

    def discover_resource(resource_name, options={})
      klass = options.fetch(:class_name, nil)
      if klass
        Object.const_get(klass)
      else
        Object.const_get("#{resource_name.to_s.classify}Resource")
      end
    end
  end
end
