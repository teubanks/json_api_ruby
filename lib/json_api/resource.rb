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
    #
    # defaults to :id
    def id
      object.public_send(self.class._primary_key)
    end

    def type
      _model.class.to_s.underscore.pluralize
    end

    attr_accessor :_model

    def initialize(model, options={})
      @_model = model
    end

    def to_hash
      resource_hash = identifier_hash
      resource_hash['attributes'] = attributes_hash

      if self.class.relationships.present?
        resource_hash['relationships'] = relationship_data
      end

      resource_hash
    end

    def identifier_hash
      { 'id' =>  self.id, 'type' =>  self.type }
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

    def relationship_data
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
      resource_class = discover_resource(options[:name].to_s.singularize, options)
      resource_instance = resource_class.new(model)
      resource_instance.identifier_hash
    end

    def discover_resource(resource_name, options={})
      namespace = options.fetch(:namespace, nil)
      klass = options.fetch(:resource_class, nil)

      klass = resource_class(resource_name, namespace) if klass.blank?

      Object.const_get(klass)
    end

    def resource_class(resource_name, namespace=nil)
      if namespace
        klass = [
          namespace.to_s.underscore,
          "#{resource_name.to_s.underscore}_resource"
        ].join('/').classify
      else
        klass = resource_path(resource_name).join.classify
      end
      klass
    end

    def resource_path(resource_name)
      current_namespace = self.class.to_s.underscore.split('/')
      current_namespace.pop
      current_namespace << '/' if current_namespace.present?
      current_namespace << "#{resource_name.to_s}_resource"
      current_namespace
    end
  end
end
