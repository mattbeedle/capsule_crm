require 'spec_helper'

class CapsuleCRM::AssociationsTest
  include Virtus
  include CapsuleCRM::Associations

  has_many :whatevers, class_name: 'CapsuleCRM::Party'

  belongs_to :something, class_name: 'CapsuleCRM::Task'
end

describe CapsuleCRM::Associations do
  describe '.has_many_associations' do
    subject { CapsuleCRM::AssociationsTest.has_many_associations }

    it 'should return a hash' do
      expect(subject).to be_a(Hash)
    end

    it 'should contain 1 item' do
      expect(subject.length).to eql(1)
    end

    it 'should contain a has many association' do
      expect(subject[:whatevers]).
        to be_a(CapsuleCRM::Associations::HasManyAssociation)
    end
  end

  describe '.belongs_to_associations' do
    subject { CapsuleCRM::AssociationsTest.belongs_to_associations }

    it 'should return a hash' do
      expect(subject).to be_a(Hash)
    end

    it 'should contain 1 item' do
      expect(subject.length).to eql(1)
    end

    it 'should contain a belongs to association' do
      expect(subject[:something]).
        to be_a(CapsuleCRM::Associations::BelongsToAssociation)
    end
  end
end
