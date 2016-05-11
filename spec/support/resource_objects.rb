module Identifiers
  def id
    self.object_id
  end

  def uuid
    @uuid ||= SecureRandom.uuid
  end
end

class Comment
  include Identifiers
  attr_accessor :author, :comment_text, :created_at, :updated_at

  def initialize(comment_text)
    @created_at = 1.day.ago
    @updated_at = 30.minutes.ago
    assign_author
  end

  def assign_author
    @author = Person.new('Archibald Monev', 'dr_venom@cobra.mil')
  end
end

class Article
  include Identifiers
  attr_accessor :publish_date, :title, :short_description, :created_at, :updated_at
  attr_reader :author
  attr_reader :comments

  def initialize(title, desc, author=nil)
    @publish_date = Time.now
    @created_at = 2.days.ago
    @updated_at = 1.day.ago
    @title = title
    @short_description = desc
    @author = author
    generate_comments
  end

  def author
    @author ||= Person.new('Ettienne R. LaFitte', 'gung_ho@recondo.mil')
  end

  def generate_comments
    @comments = [
      Comment.new("This article really cleared it up for me"),
      Comment.new("No idea what comment 1 is all about, this article was a muddled mess")
    ]
  end
end

class Person
  include Identifiers
  attr_accessor :name, :email_address, :website, :twitter, :created_at, :updated_at

  def initialize(name, email, website = nil, twitter = nil)
    @name = name
    @email_address = email
    @website = website
    @twitter = twitter
    @created_at = 1.month.ago
    @updated_at = 1.month.ago
  end

  def articles
    @articles ||= [ Article.new("How to Conquer the World", "10 simple steps to world domination", self) ]
  end
end

class PersonResource < JsonApi::Resource
  type :people
  attribute :name
  attribute :email_address
  attribute :created_at
  attribute :updated_at

  has_many :articles
end

class SubclassedPersonResource < PersonResource
  id_field :name
  attribute :website
end

class DeeplySubclassedPersonResource < SubclassedPersonResource
  attribute :twitter
end

class OverriddenSubclassedPersonResource < PersonResource
  def name
    object.name + '!!'
  end
end

class OverriddenDeeplySubclassedPersonResource < OverriddenSubclassedPersonResource
  def name
    object.name + '?'
  end
end

class ArticleResource < JsonApi::Resource
  id_field :uuid
  type :articles
  attributes :publish_date, :title, :short_description, :created_at, :updated_at

  has_one :author
  has_many :comments
end

class SimplePersonResource < JsonApi::Resource
  attribute :name
end

class SimpleCommentResource < JsonApi::Resource
  id_field :uuid
  attribute :comment_text
end

class SimpleArticleResource < JsonApi::Resource
  attribute :title

  has_one :author, resource_class: SimplePersonResource
  has_many :comments, resource_class: 'SimpleCommentResource'
end

class CommentResource < JsonApi::Resource
  id_field :uuid
  attribute :comment_text
  attribute :created_at
  attribute :updated_at

  has_one :author
end

# namespaced resources
class Two
end

class Three
end

module Namespace
  class OneResource < JsonApi::Resource
  end

  class TwoResource < JsonApi::Resource
  end
end

module DifferentNamespace
  class ThreeResource < JsonApi::Resource
  end
end
