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

  describe 'deep subclassing of Resources' do
    let(:person) { Person.new('Philip J. Fry', 'fry@thefuture.com', 'www.thefuture.com', '@philipjfry') }
    subject(:super_class_serialization) do
      PersonResource.new(person).to_hash
    end

    context 'subclasses of class whose superclass is Resource' do
      subject(:subclass_serialization) do
        SubclassedPersonResource.new(person).to_hash
      end

      it 'can override the id field of its super-class' do
        expect(subclass_serialization['id']).to eq('Philip J. Fry')
      end

      it "does not affect its super-class's list of attributes" do
        expect(PersonResource.fields).to_not eq(SubclassedPersonResource.fields)
      end

      it 'concatinates its attributes with the list of attributes from its super-class' do
        expected_attributes = super_class_serialization['attributes'].merge('website' => 'www.thefuture.com')
        expect(subclass_serialization['attributes']).to eq(expected_attributes)
      end

      it 'returns the same relationships as its super-class' do
        actual_relationship_names = subclass_serialization['relationships'].keys
        expected_relationship_names = super_class_serialization['relationships'].keys
        expect(actual_relationship_names).to eq(expected_relationship_names)
      end

      context 'with overridden attributes' do
        subject(:overridden_serialization) do
          OverriddenSubclassedPersonResource.new(person).to_hash
        end

        it 'returns overridden attributes from the subclass' do
          expect(overridden_serialization['attributes']['name']).to eq('Philip J. Fry!!')
        end
      end
    end

    context 'subclasses of subclasses of class whose superclass is Resource' do
      subject(:deep_subclass_serialization) do
        DeeplySubclassedPersonResource.new(person).to_hash
      end

      it 'can fall back to the id of its super-class' do
        expect(deep_subclass_serialization['id']).to eq('Philip J. Fry')
      end

      it 'concatinates its attributes with the list of attributes from its super-classes' do
        expected_attributes = super_class_serialization['attributes'].merge('website' => 'www.thefuture.com', 'twitter' => '@philipjfry')
        expect(deep_subclass_serialization['attributes']).to eq(expected_attributes)
      end

      it 'returns the same relationships as its super-classes' do
        expect(deep_subclass_serialization['relationships'].keys).to eq(super_class_serialization['relationships'].keys)
      end

      context 'with overridden attributes' do
        subject(:deep_overridden_serialization) do
          OverriddenDeeplySubclassedPersonResource.new(person).to_hash
        end

        it 'returns overridden attributes from the subclass' do
          expect(deep_overridden_serialization['attributes']['name']).to eq('Philip J. Fry?')
        end
      end
    end
  end
end
