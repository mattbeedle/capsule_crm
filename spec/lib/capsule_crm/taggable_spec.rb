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

    it { should be_a(Array) }

    it { subject.length.should eql(2) }

    it do
      subject.all? { |item| item.is_a?(CapsuleCRM::Tag) }.should eql(true)
    end

    it { subject.first.name.should eql('Customer') }

    it { subject.last.name.should eql('VIP') }

    context 'when taggable item has one tag' do
      before do
        stub_request(:get, /\/api\/taggableitem\/2\/tag$/).
          to_return(body: File.read('spec/support/one_tag.json'))
      end

      let(:taggable_item) { TaggableItem.new(id: 2) }

      subject { taggable_item.tags }

      it { should be_a(Array) }
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

      it { subject.should eql(true) }
    end

    context 'when the taggable item has no id' do
      let(:taggable_item) { TaggableItem.new }

      subject { taggable_item.add_tag 'A Test Tag' }

      it { subject.should be_nil }
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

      it { subject.should eql(true) }
    end

    context 'when the taggable item has no id' do
      let(:taggable_item) { TaggableItem.new }

      subject { taggable_item.remove_tag 'A Test Tag' }

      it { subject.should be_nil }
    end
  end

  describe '#api_singular_name' do
    it 'turns the class name into appropriate api name' do
      TaggableItem.new.api_singular_name.should == 'taggableitem'
    end

    it 'gives the superclass unless Object to work with Organization/Person subclassing of Party' do
      SubclassedTaggableItem.new.api_singular_name.should == 'taggableitem'
    end
  end
end
