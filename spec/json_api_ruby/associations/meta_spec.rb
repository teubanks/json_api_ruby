require 'spec_helper'

describe JsonApi::Associations::Meta do
  let(:parent_resource) { PersonResource.new(:person) }
  it 'fails on an invalid cardinality' do
    expect { JsonApi::Associations::Meta.new('person', resource_class: PersonResource, cardinality: :yeahbuddy) }.to raise_error(JsonApi::Associations::UnknownCardinalityError)
  end

  it 'builds a ToOne association' do
    new_meta = JsonApi::Associations::Meta.new('person', resource_class: PersonResource, cardinality: :one)
    expect(new_meta.build_resources({parent_resource: parent_resource})).to be_a(JsonApi::Associations::ToOne)
  end

  it 'builds a ToMany association' do
    new_meta = JsonApi::Associations::Meta.new('person', resource_class: PersonResource, cardinality: :many)
    expect(new_meta.build_resources({parent_resource: parent_resource})).to be_a(JsonApi::Associations::ToMany)
  end
end
