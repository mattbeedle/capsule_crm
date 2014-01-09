require 'spec_helper'

class Parent
  include Virtus
  include CapsuleCRM::Associations

  attribute :id, Integer

  has_many :children, class_name: 'Child', source: :parent

  def persisted?
    !!id
  end
end

class Child
  include Virtus
  include CapsuleCRM::Associations

  attribute :name

  belongs_to :parent

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
