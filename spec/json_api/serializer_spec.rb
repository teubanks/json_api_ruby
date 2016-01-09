require 'spec_helper'

RSpec.describe JsonApi::Serializer do
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
    it 'has a top level included object' do
      serialized = JsonApi.serialize(person, meta: { meta_key: 'meta value' }, include: [:articles])
      expect(serialized['included']).to be_present
    end

    it 'includes the resources as expected'
    it 'fills out the data porton of the relationships object'
  end
end
