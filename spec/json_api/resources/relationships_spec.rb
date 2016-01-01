require 'spec_helper'

RSpec.describe JSONAPI::Resources::Relationships do
  let(:article) do
    Article.new('How to raise Triops', 'Triops are hardy little creatures whose eggs can be frozen for as long as 40 years')
  end

  let(:article_resource) do
    ArticleResource.new(article)
  end

  let(:relationship_object) do
    article_resource.class.relationships.find do |rel|
      rel.name == 'author'
    end
  end

  describe 'link serialization' do
    subject(:links_object) do
      relationship_object.serialize(parent_resource: article_resource)
    end

    it 'includes a links object' do
      expect(links_object).to include('links')
    end

    it 'has a "self" object' do
      expect(links_object['links']).to include('self')
    end

    it 'has a "related" object' do
      expect(links_object['links']).to include('related')
    end

    describe 'self object' do
      it 'is a link to the relationship on the parent object' do
        expect(links_object['links']['self']).to eq "http://localhost:3000/articles/#{article.uuid}/relationships/author"
      end
    end

    describe 'related object' do
      it 'is a link to the base resource of the related object' do
        expect(links_object['links']['related']).to eq "http://localhost:3000/articles/#{article.uuid}/author"
      end
    end
  end

  describe 'data serialization' do
    it 'has a data top level object'
    describe 'data object' do
      context 'when an array' do
        it 'has an identity hash for each object'
      end

      context 'when a single object' do
        it 'has an identity hash'
      end
    end
  end

  describe 'identity hash' do
    it 'returns an identity hash given a model and parent resource'
  end

  describe 'relationship serialization' do
    context 'when the option "include" is true' do
      it 'includes the data object' do
        serialized_data = relationship_object.serialize(parent_resource: article_resource, included: true)
        expect(serialized_data).to include('data')
      end
    end

    context 'when the option "include" is falsey' do
      it 'does not include data object' do
        serialized_data = relationship_object.serialize(parent_resource: article_resource)
        expect(serialized_data).to_not include('data')
      end
    end
  end
end
