require 'spec_helper'

RSpec.describe JSONAPI::Resource do
  subject(:serialized_person) do
    person = Person.new('bob', 'painter', 'heaven')
    PersonResource.new(person).to_hash
  end

  it 'is follows the JSON API spec' do
    expect(serialized_person).to be_valid_json_api
  end

  it 'has a name with the value "bob"' do
    expect(serialized_person).to have_attribute(:name).with_value('bob')
  end

  it 'has an occupation with the value "painter"' do
    expect(serialized_person).to have_attribute(:occupation).with_value('painter')
  end

  it 'has an address with the value "heaven"' do
    expect(serialized_person).to have_attribute(:address).with_value('heaven')
  end

  it 'has an updated_at timestamp with the value "1234567890"' do
    expect(serialized_person).to have_attribute(:updated_at).with_value(1234567890)
  end

  describe 'relationships' do
    context 'with a cardinality of one' do
      subject(:serialized_resource) do
        person = Person.new('bob', 'painter', 'heaven')
        PersonResource.new(person).to_hash
      end

      it 'includes the relationship keys' do
        expect(serialized_resource).to have_relationship('phone')
      end

      it 'have a valid phone relationship' do
        expect(serialized_resource['relationships']['phone']['data']).to be_valid_json_api
      end
    end

    context 'with a cardinality of many' do
      subject(:serialized_resource) do
        person = Person.new('bob', 'painter', 'heaven')
        PersonResource.new(person).to_hash
      end

      it 'includes relationship data' do
        expect(serialized_resource).to have_relationship('cars')
      end

      it 'includes the type for the relationship' do
        serialized_resource['relationships']['cars']['data'].map do |car|
          expect(car).to be_valid_json_api
          expect(car['type']).to eq 'cars'
        end
      end

      it 'includes the id for the relationship' do
        serialized_resource['relationships']['cars']['data'].map do |car|
          expect(car['id'].length).to eq 36
        end
      end
    end
  end

  describe 'link paths' do
    let(:person) { Person.new('bob', 'painter', 'heaven') }
    subject(:serialized_person) do
      PersonResource.new(person).to_hash
    end

    it 'returns a full URL to the resource' do
      expect(serialized_person['links']['self']).to eq("http://localhost:3000/people/#{person.id}")
    end
  end
end
