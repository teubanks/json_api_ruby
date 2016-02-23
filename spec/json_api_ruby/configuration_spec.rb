require 'spec_helper'

describe JsonApi::Configuration do
  subject('configuration') { JsonApi.configuration }
  specify { expect(subject.base_url).to eq 'http://localhost:3000' }
  specify { expect(subject.use_links).to be_truthy }

  it 'allows overidding the base url' do
    subject.base_url = 'https://google.com'
    expect(subject.base_url).to eq 'https://google.com'
  end

  it 'allows overidding the use_links option' do
    subject.use_links = false
    expect(subject.use_links).to be_falsy
  end
end
