require 'spec_helper'

RSpec.describe JsonApi::Resource do
  subject(:serialized_person) do
    person = Person.new('Brad J. Armbruster', 'ace@airforce.mil')
    PersonResource.new(person).to_hash
  end

  it 'is follows the JSON API spec' do
    expect(serialized_person).to be_valid_json_api
  end

  it 'has a name with the value "Brad J. Armbruster"' do
    expect(serialized_person).to have_attribute(:name).with_value('Brad J. Armbruster')
  end

  it 'has an email with the value "ace@airforce.mil"' do
    expect(serialized_person).to have_attribute(:email_address).with_value('ace@airforce.mil')
  end

  it 'has a created_at field' do
    expect(serialized_person).to have_attribute(:created_at)
  end

  it 'has an updated_at timestamp' do
    expect(serialized_person).to have_attribute(:updated_at)
  end

  describe 'relationships' do
    subject(:serialized_article) do
      article = Person.new('Anatoly Fyodorovich Krimov', 'red_star@kremlin.mil').articles.first
      ArticleResource.new(article, include: [:author, :comments]).to_hash
    end

    context 'with a cardinality of one' do
      it 'includes the relationship keys' do
        expect(serialized_article).to have_relationship('author')
      end

      it 'have a valid author relationship' do
        expect(serialized_article['relationships']['author']['data']).to be_valid_json_api
      end
    end

    context 'with a cardinality of many' do
      it 'includes relationship data' do
        expect(serialized_article).to have_relationship('comments')
      end

      it 'includes the type for the relationship' do
        serialized_article['relationships']['comments']['data'].map do |comment|
          expect(comment).to be_valid_json_api
          expect(comment['type']).to eq 'comments'
        end
      end

      it 'includes the id for the relationship' do
        serialized_article['relationships']['comments']['data'].map do |comment|
          expect(comment['id'].length).to eq 36
        end
      end
    end

    context 'relationship links' do
      subject(:serialized_article) do
        article = Person.new('Anatoly Fyodorovich Krimov', 'red_star@kremlin.mil').articles.first
        ArticleResource.new(article).to_hash
      end

      it 'includes links to for the comments relationship' do
        expect(serialized_article).to have_links_for('comments')
      end

      it 'includes links for the author relationship' do
        expect(serialized_article).to have_links_for('author')
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
