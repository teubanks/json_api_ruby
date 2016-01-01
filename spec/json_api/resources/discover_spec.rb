require 'spec_helper'
RSpec.describe JsonApi::Resources::Discovery do
  describe 'resource discovery' do
    it 'finds a resource class created within the same namespace' do
      rs1 = Namespace::OneResource.new(nil)
      expect(JsonApi::Resources::Discovery.resource_for_name(Two.new, {parent_resource: rs1})).to eq Namespace::TwoResource
    end

    it 'allows specifying a different namespace' do
      expect(JsonApi::Resources::Discovery.resource_for_name(Three.new, namespace: 'different_namespace')).to eq DifferentNamespace::ThreeResource
    end

    it 'allows explicitly providing a resource class' do
      expect(JsonApi::Resources::Discovery.resource_for_name(Two.new, resource_class: 'DifferentNamespace::ThreeResource')).to eq DifferentNamespace::ThreeResource
    end

    it "raises an error if the resource can't be found" do
      expect {
        JsonApi::Resources::Discovery.resource_for_name(nil)
      }.to raise_error JsonApi::ResourceNotFound
    end
  end
end
