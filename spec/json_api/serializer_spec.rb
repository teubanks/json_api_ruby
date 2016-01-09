require 'spec_helper'

RSpec.describe JsonApi::Serializer do
  context 'a single object' do
    let(:person) do
      Person.new('Brad J. Armbruster', 'ace@airforce.mil')
    end

    subject(:serialized_data) do
      JsonApi.serialize(person, meta: { meta_key: 'meta value' })
    end

    it 'has a top level data object' do
      expect(serialized_data).to have_data
    end

    it 'passes meta through' do
      expect(serialized_data).to have_meta
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
