module JsonApi
  # Builds a traversible representation of the included resources
  class Includes
    attr_reader :name
    attr_writer :includes
    attr_writer :next

    # Returns:
    #   #<Includes>
    def self.parse_includes(includes)
      first_include = self.new

      split_includes = Array(includes).map{|inc| inc.to_s.split('.')}
      split_includes = ArrayTransposer.new(split_includes).transpose_array
      first_array = split_includes.shift
      first_include.includes = Array(first_array).uniq.compact

      split_includes.inject(first_include) do |base_include, sub_array|
        new_include = self.new
        new_include.includes = sub_array.uniq.compact
        base_include.next = new_include
        new_include
      end

      first_include
    end

    def has_name?(name)
      includes.include?(name)
    end

    def includes
      @includes || []
    end

    def next
      @next || self.class.new
    end

  end

  class ArrayTransposer
    attr_reader :array

    def initialize(array)
      @array = Array(array)
    end

    def transpose_array
      padded_sub_arrays.transpose
    end

    def padded_sub_arrays
      max_length = largest_sub_array_length
      array.map do |sub_array|
        sub_array.extend(ArrayPadder)
        sub_array.pad(max_length)
      end
    end

    def largest_sub_array_length
      largest_count = 0
      array.each do |sub_array|
        largest_count = sub_array.count if sub_array.length > largest_count
      end
      largest_count
    end
  end

  # Meant to be extended within an Array instance
  module ArrayPadder
    def pad(length)
      self + self.class.new(length - self.length) { nil }
    end
  end
end
