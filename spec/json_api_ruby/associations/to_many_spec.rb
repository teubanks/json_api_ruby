require 'spec_helper'

class ResourceObject
  def identifier_hash
    {}
  end
end

describe JsonApi::Associations::ToMany do
  subject(:assoc_instance) do
    assoc = described_class.new('tomanytest', parent_resource: double('person_resource', _model: nil), explicit_resource_class: nil)
    assoc.instance_variable_set(:@resources, [ResourceObject.new])
    assoc
  end

  it 'builds a data hash' do
    expect(assoc_instance.data).to eq({'data' => [{}]})
  end

  it 'returns nil when no resources are present' do
    assoc = described_class.new('toonetest', parent_resource: double('person_resource', _model: nil), explicit_resource_class: nil)
    expect(assoc.data).to eq({'data' => []})
  end

  it 'returns its resource objects' do
    expect(assoc_instance.resource_objects).to be_an Array
  end

  it 'returns `many` for its cardinality' do
    expect(assoc_instance.cardinality).to eq :many
  end

  context 'is included' do
    it 'builds its included resources' do
      article = Article.new('How to raise Triops', 'Triops are hardy little creatures whose eggs can be frozen for as long as 40 years')
      article_resource = ArticleResource.new(article)
      options = {
        parent_resource: article_resource,
        explicit_resource_class: CommentResource,
        included: JsonApi::Includes.parse_includes(['comments'])
      }
      comment_assoc = described_class.new('comments', options)
      comment_assoc.build_resources(options)
      expect(comment_assoc.resource_objects.count).to eq article.comments.count
    end
  end

  context 'is not included' do
    it 'returns nil' do
      article = Article.new('How to raise Triops', 'Triops are hardy little creatures whose eggs can be frozen for as long as 40 years')
      article_resource = ArticleResource.new(article)
      options = {
        parent_resource: article_resource,
        explicit_resource_class: CommentResource
      }
      comment_assoc = described_class.new('comments', options)
      comment_assoc.build_resources(options)
      expect(comment_assoc.resource_objects.count).to eq 0
    end
  end
end
