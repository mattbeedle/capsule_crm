require 'spec_helper'

class CapsuleCRM::BelongsToAssociationTest
  include Virtus.model

  attribute :name

  def self.find(id)
    new(name: 'test')
  end
end

describe CapsuleCRM::Associations::BelongsToAssociation do
  let(:association_name) { Faker::Lorem.word.to_sym }
  let(:defined_on) { double }
  let(:options) do
    { class_name: 'CapsuleCRM::BelongsToAssociationTest' }
  end
  let(:association) do
    CapsuleCRM::Associations::BelongsToAssociation.
      new(association_name, defined_on, options)
  end

  describe '#macro' do
    subject { association.macro }

    it 'should return :belongs_to' do
      expect(subject).to eql(:belongs_to)
    end
  end

  describe '#foreign_key' do
    context 'when a foreign_key is not supplied' do
      subject { association.foreign_key }

      it 'should build the foreign key' do
        expect(subject).to eql("#{association_name}_id")
      end
    end

    context 'when a foreign key is supplied' do
      before { options.merge!(foreign_key: 'bleurgh') }
      subject { association.foreign_key }

      it 'should return the supplied foreign key' do
        expect(subject).to eql(options[:foreign_key])
      end
    end
  end

  describe '#serializable_key' do
    subject { association.serializable_key }
    context 'when a serializable_key is supplied' do
      let(:serializable_key) { Faker::Lorem.word }
      before { options.merge!(serializable_key: serializable_key) }

      it 'should return the serializable_key' do
        expect(subject).to eql(serializable_key)
      end
    end

    context 'when a serializable_key is not supplied' do
      it 'should return the foreign key' do
        expect(subject).to eql(association.foreign_key)
      end
    end
  end

  describe '#object' do
    before { options.merge!(foreign_key: :some_id) }
    let(:object) { double(some_id: Random.rand(1..10)) }
    subject { association.parent(object) }

    it 'should return the parent' do
      expect(subject).to be_a(CapsuleCRM::BelongsToAssociationTest)
    end
  end
end
