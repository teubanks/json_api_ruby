module JsonApi
  class Configuration
    attr_accessor :base_url
    attr_accessor :use_links

    DEFAULTS = {
      base_url: 'http://localhost:3000',
      use_links: true
    }

    def initialize
      DEFAULTS.each do |key, value|
        self.instance_variable_set("@#{key}", value)
      end
    end
  end

  class << self
    attr_accessor :configuration
  end

  @configuration = Configuration.new
end
