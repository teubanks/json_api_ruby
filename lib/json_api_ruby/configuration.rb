module JsonApi
  class Configuration
    attr_reader :base_url

    def initialize
      @base_url = 'http://localhost:3000'
    end
  end

  class << self
    attr_accessor :configuration
  end

  @configuration = Configuration.new
end
