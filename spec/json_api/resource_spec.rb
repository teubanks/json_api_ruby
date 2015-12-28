require 'spec_helper'

RSpec.describe JSONAPI::Resource do
  subject(:serialized_person) do
    person = Person.new('Brad J. Armbruster', 'ace@airforce.mil')
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

  it 'has an updated_at timestamp' do
    expect(serialized_person).to have_attribute(:updated_at)
  end

  describe 'relationships' do
    subject(:serialized_resource) do
      article = Person.new('Anatoly Fyodorovich Krimov', 'red_star@kremlin.mil').articles.first
      ArticleResource.new(article).to_hash
    end

    context 'with a cardinality of one' do
      it 'includes the relationship keys' do
        expect(serialized_resource).to have_relationship('author')
      end

      it 'have a valid phone relationship' do
        expect(serialized_resource['relationships']['author']['data']).to be_valid_json_api
      end
    end

    context 'with a cardinality of many' do
      it 'includes relationship data' do
        expect(serialized_resource).to have_relationship('comments')
      end

      it 'includes the type for the relationship' do
        serialized_resource['relationships']['comments']['data'].map do |comment|
          expect(comment).to be_valid_json_api
          expect(comment['type']).to eq 'comments'
        end
      end

      it 'includes the id for the relationship' do
        serialized_resource['relationships']['comments']['data'].map do |comment|
          expect(comment['id'].length).to eq 36
        end
      end
    end
  end

  describe 'link paths' do
    let(:person) { Person.new('Sherman R. Guderian', 'heavy_metal@airforce.mil') }
    subject(:serialized_person) do
      PersonResource.new(person).to_hash
    end

    it 'returns a full URL to the resource' do
      expect(serialized_person['links']['self']).to eq("http://localhost:3000/people/#{person.id}")
    end
  end
end
