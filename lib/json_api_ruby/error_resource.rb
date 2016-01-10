class ErrorResource
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def to_hash
    { 'detail' => object }
  end
end
