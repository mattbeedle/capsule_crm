require 'spec_helper'

class Parent
  include Virtus
  include CapsuleCRM::Associations::HasMany

  attribute :id, Integer

  has_many :children, class_name: 'Child', source: :parent
end

class Child
  include Virtus
  include CapsuleCRM::Associations::BelongsTo

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
    before { parent.children.create(name: 'a test name') }

    it 'should persist the child' do
      parent.children.last.should be_persisted
    end
  end
end
