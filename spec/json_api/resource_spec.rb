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

class PhoneResource < JSONAPI::Resource
  attribute :manufacturer
  attribute :model
  attribute :number

  has_one :person
end

class CarResource < JSONAPI::Resource
  attribute :make
  attribute :model
  attribute :year
  attribute :color

  def id
    object.uuid
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

  describe 'relationships' do
    context 'with a cardinality of one' do
      let(:serialized_resource) do
        person = Person.new('bob', 'painter', 'heaven')
        PersonResource.new(person).to_hash
      end

      it 'includes the relationship keys' do
        expect(serialized_resource['relationships']['phone']).to_not be_nil
      end

      it 'includes the type for the relationship' do
        expect(serialized_resource['relationships']['phone']['data']['type']).to eq('phones')
      end

      it 'includes the id for the relationship' do
        expect(serialized_resource['relationships']['phone']['data']['id']).to eq 1
      end
    end

    context 'with a cardinality of many' do
      let(:serialized_resource) do
        person = Person.new('bob', 'painter', 'heaven')
        PersonResource.new(person).to_hash
      end

      it 'includes relationship data' do
        expect(serialized_resource['relationships']['cars']).to_not be_nil
      end

      it 'includes the type for the relationship' do
        serialized_resource['relationships']['cars']['data'].map do |car|
          expect(car['type']).to eq 'cars'
        end
      end

      it 'includes the id for the relationship' do
        serialized_resource['relationships']['cars']['data'].map do |car|
          expect(car['id']).to_not be_blank
          expect(car['id'].length).to eq 36
        end
      end
    end
  end
end
