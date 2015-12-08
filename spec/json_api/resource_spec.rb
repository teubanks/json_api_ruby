require 'spec_helper'

class PersonResource < JSONAPI::Resource
  attribute :name
  attribute :occupation
  attribute :address

  # has_one :phone
end

RSpec.describe JSONAPI::Resource do
  it 'should serialize specified attributes' do
    person = Person.new('bob', 'painter', 'heaven')
    expected_hash = {
      id: '91f37652-c015-4e04-ba55-815fb5407d12',
      type: 'people',
      attributes: {
        name: 'bob',
        occupation: 'painter',
        address: 'heaven'
      }
    }

    serialized = PersonResource.new(person).to_hash
    expect(serialized['id']).to eq expected_hash[:id]
    expect(serialized['type']).to eq expected_hash[:type]
    expect(serialized['attributes']).to eq expected_hash[:attributes]
  end
end
