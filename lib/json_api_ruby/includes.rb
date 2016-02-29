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
      if split_includes.blank?
        return first_include
      end

      first_array = Array(split_includes.first)
      other_arrays = split_includes[1..-1]
      zipped = first_array.zip(*other_arrays)
      first_array = zipped.shift
      first_include.includes = first_array.uniq.compact

      zipped.inject(first_include) do |base_include, object_name|
        new_include = self.new
        new_include.includes = object_name.uniq.compact
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
end
