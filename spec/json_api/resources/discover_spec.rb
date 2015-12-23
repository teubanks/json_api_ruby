require 'spec_helper'
RSpec.describe JSONAPI::Resources::Discovery do
  describe 'resource discovery' do
    it 'finds a resource class created within the same namespace' do
      rs1 = Namespace::OneResource.new(nil)
      expect(JSONAPI::Resources::Discovery.resource_for_name(:two, {parent_resource: rs1})).to eq Namespace::TwoResource
    end

    it 'allows specifying a different namespace' do
      expect(JSONAPI::Resources::Discovery.resource_for_name(:three, namespace: 'different_namespace')).to eq DifferentNamespace::ThreeResource
    end

    it 'allows explicitly providing a resource class' do
      expect(JSONAPI::Resources::Discovery.resource_for_name(:two, resource_class: 'DifferentNamespace::ThreeResource')).to eq DifferentNamespace::ThreeResource
    end

    it "raises an error if the resource can't be found" do
      expect {
        JSONAPI::Resources::Discovery.resource_for_name(:not_a)
      }.to raise_error JSONAPI::ResourceNotFound
    end
  end
end
