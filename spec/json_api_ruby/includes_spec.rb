require 'spec_helper'

describe JsonApi::Includes do
  context 'with nil' do
    subject(:parsed_with_nil) { described_class.parse_includes(nil) }
    specify { expect(parsed_with_nil.includes).to eq [] }
    specify { expect(parsed_with_nil.next).to be_an_instance_of(JsonApi::Includes) }
  end

  context 'with nested resources using the "." syntax' do
    it 'has an includes array' do
      parsed_includes = described_class.parse_includes(['thingone', 'thingtwo'])
      expect(parsed_includes.includes).to eq ['thingone', 'thingtwo']
    end

    it 'has a reference to nested objects' do
      parsed_includes = described_class.parse_includes(['thingone.thingtwo'])
      expect(parsed_includes.next.includes).to eq ['thingtwo']
    end

    it 'handles triple nesting' do
      parsed_includes = described_class.parse_includes(['thingone.thingtwo.thingthree'])
      expect(parsed_includes.next.next.includes).to eq ['thingthree']
    end

    context 'complex includes' do
      subject(:parsed_includes) do
        described_class.parse_includes(['thingone.thingtwo.thingthree', 'thingone.thingfour', 'thingone.thingtwo.thingfive', 'thingsix.thingseven'])
      end

      specify { expect(parsed_includes.includes).to eq ['thingone', 'thingsix'] }
      specify { expect(parsed_includes.next.includes).to eq ['thingtwo', 'thingfour', 'thingseven'] }
      specify { expect(parsed_includes.next.next.includes).to eq ['thingthree', 'thingfive'] }
    end
  end

  describe 'flattened hash' do
    subject(:flattened) do
      described_class.flatten_hash(hash)
    end

    context 'given the deeply nested hash { foo: { bar: :baz } }' do
      let(:hash) do
        { foo: { bar: :baz } }
      end
      let(:expected_ary) { ['foo', 'bar', 'baz'] }

      it { expect(flattened).to eq expected_ary }
    end
  end
end
