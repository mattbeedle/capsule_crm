require 'spec_helper'

class TaggableItem
  include CapsuleCRM::Taggable
  include Virtus.model

  attribute :id
end

class SubclassedTaggableItem < TaggableItem
end

describe CapsuleCRM::Taggable do
  before { configure }

  describe '#tags' do
    before do
      stub_request(:get, /\/api\/taggableitem\/1\/tag$/).
        to_return(body: File.read('spec/support/all_tags.json'))
    end

    let(:taggable_item) { TaggableItem.new(id: 1) }

    subject { taggable_item.tags }

    it { is_expected.to be_a(Array) }

    it { expect(subject.length).to eql(2) }

    it do
      result = subject.all? { |item| item.is_a?(CapsuleCRM::Tag) }
      expect(result).to eql(true)
    end

    it { expect(subject.first.name).to eql('Customer') }

    it { expect(subject.last.name).to eql('VIP') }

    context 'when taggable item has one tag' do
      before do
        stub_request(:get, /\/api\/taggableitem\/2\/tag$/).
          to_return(body: File.read('spec/support/one_tag.json'))
      end

      let(:taggable_item) { TaggableItem.new(id: 2) }

      subject { taggable_item.tags }

      it { is_expected.to be_a(Array) }
    end
  end

  describe '#add_tag' do
    context 'when the taggable item has an id' do
      let(:taggable_item) { TaggableItem.new(id: 1) }

      before do
        loc = 'https://sample.capsulecrm.com/api/party/1000/tag/A%20Test%20Tag'
        stub_request(:post, /\/api\/taggableitem\/1\/tag\/A%20Test%20Tag$/).
          to_return(headers: { 'Location' =>  loc })
      end

      subject { taggable_item.add_tag 'A Test Tag' }

      it { expect(subject).to eql(true) }
    end

    context 'when the taggable item has no id' do
      let(:taggable_item) { TaggableItem.new }

      subject { taggable_item.add_tag 'A Test Tag' }

      it { expect(subject).to be_nil }
    end
  end

  describe '#remove_tag' do

    subject { taggable_item.remove_tag 'A Test Tag' }

    context 'when the taggable item has an id' do
      let(:taggable_item) { TaggableItem.new(id: 1) }

      before do
        loc = 'https://sample.capsulecrm.com/api/party/1000/tag/A%20Test%20Tag'
        stub_request(:delete, /\/api\/taggableitem\/1\/tag\/A%20Test%20Tag$/).
          to_return(headers: { 'Location' => loc })
      end

      it { expect(subject).to eql(true) }
    end

    context 'when the taggable item has no id' do
      let(:taggable_item) { TaggableItem.new }

      subject { taggable_item.remove_tag 'A Test Tag' }

      it { expect(subject).to be_nil }
    end
  end

  describe '#api_singular_name' do
    it 'turns the class name into appropriate api name' do
      expect(TaggableItem.new.api_singular_name).to eql('taggableitem')
    end

    it 'gives the superclass unless Object to work with Organization/Person subclassing of Party' do
      expect(SubclassedTaggableItem.new.api_singular_name)
        .to eql('taggableitem')
    end
  end
end
