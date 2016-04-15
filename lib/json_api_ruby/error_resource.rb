class ErrorResource
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def to_hash
    tf = CoverageTestFile.new
    tf.is_test?
    tf.print_description
    { 'detail' => object }
  end
end
