require 'rspec/expectations'

RSpec::Matchers.define :have_relationship do |expected|
  match do |actual|
    relationships = Hash(actual).stringify_keys['relationships']
    Hash(relationships).keys.include?(expected)
  end
end

RSpec::Matchers.define :have_attribute do |key_name|
  match do |actual|
    attributes = Hash(actual).stringify_keys['attributes']
    return false unless attributes.keys.include?(key_name.to_s)
    attributes[key_name.to_s] == @expected_value
  end

  chain :with_value do |key_value|
    @expected_value = key_value
  end
end

RSpec::Matchers.define :be_valid_json_api do
  match do |actual|
    return false unless actual.is_a?(Hash)
    actual.stringify_keys
    return false unless actual['id'] && actual['type']
    true
  end
end
