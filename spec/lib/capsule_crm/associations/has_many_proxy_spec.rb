require 'spec_helper'

class Parent
  include Virtus
  include CapsuleCRM::Associations

  class_attribute :connection_options
  self.connection_options = {
    plural: 'people'
  }

  attribute :id, Integer

  has_many :children, class_name: 'Child', source: :parent
  has_many :embedded_children, class_name: 'Child', source: :parent_as_embedded,
    embedded: true

  def persisted?
    !!id
  end
end

class Child
  include Virtus
  include CapsuleCRM::Associations
  include CapsuleCRM::Serializable

  class_attribute :connection_options
  self.connection_options = {
    collection_name: 'childs', plural: 'children'
  }

  attribute :name

  belongs_to :parent, class_name: 'Parent'
  belongs_to :parent_as_embedded, class_name: 'Parent'

  def self._for_parent(parent_id)
    []
  end

  def save
    @persisted = true
  end

  def persisted?
    @persisted
  end
end

describe CapsuleCRM::Associations::HasManyProxy do
  let(:proxy) do
    CapsuleCRM::Associations::HasManyProxy.new(
      parent, Child, target, :parent
    )
  end
  let(:parent) { Parent.new }
  let(:target) { [] }
  before { configure }

  describe '#build' do
    before { parent.children.build(name: 'a test name') }

    it 'should build a child object' do
      parent.children.first.should be_a(Child)
    end

    it 'should set the child object attributes' do
      parent.children.first.name.should eql('a test name')
    end

    it 'should add an object to the target' do
      parent.children.length.should eql(1)
    end

    it 'should add the target to the parent' do
      parent.children.length.should eql(1)
    end
  end

  describe '#create' do
    context 'when the child is embedded' do
      let(:name) { Faker::Lorem.word }
      subject { parent.embedded_children.create(name: name) }

      context 'when the parent is persisted' do
        before do
          stub_request(:put, /.*/).to_return(status: 200)
          parent.id = Random.rand(1..10)
          subject
        end

        it 'should send a put request to capsule' do
          expect(WebMock).to have_requested(
            :put, "https://1234:@company.capsulecrm.com/api/people/#{parent.id}/children"
          ).with(body: { childs: [{ child: { name: name } }] })
        end
      end
    end

    context 'when the child is not embedded' do
      subject { parent.children.create(name: 'a test name') }

      context 'when the parent is persisted' do
        before do
          parent.id = Random.rand(1..10)
          subject
        end

        it 'should persist the child' do
          expect(parent.children.last).to be_persisted
        end
      end

      context 'when the parent is not persisted' do
        it 'should raise a RecordNotSaved error' do
          expect { subject }.to raise_error(CapsuleCRM::Errors::RecordNotSaved)
        end
      end
    end
  end
end
