module JSONAPI
  class Resource
    attr_accessor :_model
    def initialize(model)
      @_model = model
    end

    def to_hash
      {
        'id' =>  @_model.id,
        'type' =>  @_model.to_s,
        'attributes' =>  attributes_hash
      }
    end

    def attributes_hash
      Hash.new.tap do |h|
        self.class.fields.each do |attr|
          h[attr] = @_model.send(attr)
        end
      end
    end

    class << self
      attr :fields

      def attribute(attr)
        @fields ||= []
        @fields << attr
      end
    end
  end
end
