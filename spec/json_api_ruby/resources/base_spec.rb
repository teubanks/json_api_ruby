require 'spec_helper'

class BaseTestClass < JsonApi::Resource
end

describe BaseTestClass do
  let!(:person) do
    Person.new('Brad J. Armbruster', 'ace@airforce.mil')
  end

  subject(:test_class) { described_class.new(person) }

  it 'provides a links hash' do
    expect(test_class.links_hash).to eq({ 'self' => "http://localhost:3000/people/#{person.id}" })
  end

  it 'provides a links hash' do
    expect(test_class.to_hash['links']).to be_present
  end

  it "doesn't include links if configuration has them turned off" do
    BaseTestClass.instance_variable_set(:@_use_links, false)
    expect(test_class.to_hash['links']).to be_blank
  end
end
