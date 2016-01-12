require 'spec_helper'

RSpec.describe JsonApi::Resources::RelationshipMeta do
  let(:article) do
    Article.new('How to raise Triops', 'Triops are hardy little creatures whose eggs can be frozen for as long as 40 years')
  end

  let(:article_resource) do
    ArticleResource.new(article)
  end

  let(:author_relation) do
    article_resource.class.relationships.find do |rel|
      rel.name == 'author'
    end
  end

  let(:comments_relation) do
    article_resource.class.relationships.find do |rel|
      rel.name == 'comments'
    end
  end

  describe 'link serialization' do
    subject(:links_object) do
      rel = author_relation.build_resources(parent_resource: article_resource)
      rel.to_hash
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
    subject(:serialized_object) do
      rel = author_relation.build_resources(parent_resource: article_resource, included: true)
      rel.to_hash
    end

    it 'has a data top level object' do
      expect(serialized_object).to include('data')
    end

    describe 'data object' do
      context 'when an array' do
        subject(:serialized_object) do
          rel = comments_relation.build_resources(parent_resource: article_resource, included: true)
          rel.to_hash
        end

        it 'has an identity hash for each object' do
          expect(serialized_object['data'].flat_map(&:keys).uniq).to eq ['id', 'type']
        end
      end

      context 'when a single object' do
        it 'has an identity hash' do
          expect(serialized_object['data'].keys).to eq ['id', 'type']
        end
      end
    end
  end

  describe 'identity hash' do
    it 'returns an identity hash given a model and parent resource' do
      rel = author_relation.build_resources(parent_resource: article_resource, included: true)
      serialized_object = rel.to_hash
      expect(serialized_object['data'].keys).to eq ['id', 'type']
    end
  end

  describe 'relationship serialization' do
    context 'when the option "include" is true' do
      it 'includes the data object' do
        rel = author_relation.build_resources(parent_resource: article_resource, included: true)
        serialized_data = rel.to_hash
        expect(serialized_data).to include('data')
      end
    end

    context 'when the option "include" is falsey' do
      it 'does not include data object' do
        rel = author_relation.build_resources(parent_resource: article_resource)
        serialized_data = rel.to_hash
        expect(serialized_data).to_not include('data')
      end
    end
  end
end
