require 'spec_helper'

class PersonResource < JSONAPI::Resource
  attribute :name
  attribute :occupation
  attribute :address
  attribute :updated_at

  has_one :phone
  has_many :cars

  def updated_at
    1234567890
  end
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
        address: 'heaven',
        updated_at: 1234567890
      }
    }

    serialized = PersonResource.new(person).to_hash
    expect(serialized['id']).to eq expected_hash[:id]
    expect(serialized['type']).to eq expected_hash[:type]
    expect(serialized['attributes']).to eq expected_hash[:attributes].stringify_keys
  end

  it 'uses methods as defined on the resource object' do
    person = Person.new('bob', 'painter', 'heaven')
    serialized = PersonResource.new(person).to_hash
    expect(serialized['attributes']['updated_at']).to be_present
  end

  it 'serializes has_one relationship data' do
    person = Person.new('bob', 'painter', 'heaven')
    serialized = PersonResource.new(person).to_hash
    expect(serialized['relationships']['phone']).to_not be_nil
  end

  it 'serializes has_many relationship data' do
    person = Person.new('bob', 'painter', 'heaven')
    serialized = PersonResource.new(person).to_hash
    expect(serialized['relationships']['cars']).to_not be_nil
  end
end
