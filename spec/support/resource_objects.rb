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
  attr_accessor :name, :email_address, :created_at, :updated_at

  def initialize(name, email)
    @name = name
    @email_address = email
    @created_at = 1.month.ago
    @updated_at = 1.month.ago
  end

  def articles
    [ Article.new("How to Conquer the World", "10 simple steps to world domination", self) ]
  end
end

class PersonResource < JSONAPI::Resource
  attribute :name
  attribute :email_address
  attribute :created_at
  attribute :updated_at

  has_many :articles
end

class ArticleResource < JSONAPI::Resource
  id_field :uuid
  attributes :publish_date, :title, :short_description, :created_at, :updated_at

  has_one :author
  has_many :comments
end

class CommentResource < JSONAPI::Resource
  id_field :uuid
  attribute :author
  attribute :comment_text
  attribute :created_at
  attribute :updated_at
end

# namespaced resources
class Two
end

class Three
end

module Namespace
  class OneResource < JSONAPI::Resource
  end

  class TwoResource < JSONAPI::Resource
  end
end

module DifferentNamespace
  class ThreeResource < JSONAPI::Resource
  end
end

