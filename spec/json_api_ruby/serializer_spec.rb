require 'spec_helper'

RSpec.describe JsonApi::Serializer do
  context 'a single object' do
    let(:person) do
      Person.new('Brad J. Armbruster', 'ace@airforce.mil')
    end

    subject(:serialized_data) do
      JsonApi.serialize(person, meta: { meta_key: 'meta value' })
    end

    subject(:serialized_data_other_resource_class) do
      JsonApi.serialize(person, resource_class: 'Namespace::OneResource')
    end

    it 'returns a nil data object for no objects' do
      expect(JsonApi.serialize(nil)).to eq({'data' => nil})
    end

    it 'has a top level data object' do
      expect(serialized_data).to have_data
    end

    it 'passes meta through' do
      expect(serialized_data).to have_meta
    end

    it 'serializes the data using the passed-in resource class' do
      expected_keys = %w(id type links)
      expect(serialized_data_other_resource_class['data']).to be_valid_json_api
      expect(serialized_data_other_resource_class['data'].keys).to eql(expected_keys)
    end

    context 'with included resources' do
      subject(:serialized) do
        JsonApi.serialize(person, meta: { meta_key: 'meta value' }, include: [:articles])
      end

      it 'has a top level included object' do
        expect(serialized['included']).to be_present
      end

      it 'includes the resources as expected' do
        found_document = serialized['included'].select do |document|
          document['id'] == person.articles.first.uuid
        end
        expect(found_document).to be_present
      end

      context 'deeply nested' do
        describe 'requested included data' do
          subject(:comments) do
            serialized['included'].select do |document|
              document['type'] == 'comments'
            end
          end
          subject(:author) do
            serialized['included'].detect do |document|
              document['type'] == 'people'
            end
          end

          context 'with string arguments' do
            let(:serialized) { JsonApi.serialize(person, include: ['articles.comments.author']) }
            it { expect(comments).to be_present }
            it { expect(author).to be_present }
          end

          context 'with hash arguments' do
            let(:serialized) { JsonApi.serialize(person, include: [{ articles: { comments: :author } }]) }
            it { expect(comments).to be_present }
            it { expect(author).to be_present }
          end
        end
      end
    end
  end

  context 'a collection of objects' do
    let(:people) do
      [
        Person.new('Brad J. Armbruster', 'ace@airforce.mil'),
        Person.new('Sabastian Bludd', 'sbludd@cobra.mil'),
        Person.new('John Zullo', 'ace@specops.mil')
      ]
    end

    subject(:serialized_collection_other_resource_class) do
      JsonApi.serialize(people, resource_class: 'Namespace::OneResource')
    end

    it 'returns an empty data array for no objects' do
      expect(JsonApi.serialize([])).to eq({'data' => []})
    end

    it 'serializes the data using the passed-in resource class' do
      serialized_collection_other_resource_class['data'].each do |serialized|
        expected_keys = %w(id type links)
        expect(serialized).to be_valid_json_api
        expect(serialized.keys).to eql(expected_keys)
      end
    end

    context 'without included resources' do
      subject(:serialized_resources) do
        JsonApi.serialize(people, meta: {'I' => 'have meta'})
      end

      it 'has three data objects' do
        expect(serialized_resources).to have_data
      end

      it 'passes meta through' do
        expect(serialized_resources).to have_meta
      end
    end

    context 'with included resources' do
      subject(:serialized_resources) do
        people.first.articles << people.second.articles.first
        people.second.articles << people.first.articles.first
        JsonApi.serialize(people, meta: {'I' => 'have meta'}, include: [:articles])
      end

      it 'has included resources' do
        expect(serialized_resources['included']).to be_present
      end

      it 'includes resources only once' do
        included_identifiers = serialized_resources['included'].map do |resource|
          resource['id'] + resource['type']
        end
        unique_identifiers = included_identifiers.uniq
        unique_identifiers.each do |id|
          all_ids = included_identifiers.select {|inc_id| inc_id == id}
          expect(all_ids.length).to eq 1
        end
      end
    end
  end
end
