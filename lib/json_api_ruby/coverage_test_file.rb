class CoverageTestFile
  def initialize
    @is_test = true
  end

  def is_test?
    @is_test == true
  end

  def print_description
    which = "this file"
    what = "tests code coverage"
    puts "#{which} #{what}"
  end
end
