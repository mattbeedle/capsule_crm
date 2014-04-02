require 'spec_helper'

class CapsuleCRM::SomeClass
  include Virtus.model

  attribute :name

  def self._for_mock(mock_id)
    ['test']
  end
end

describe CapsuleCRM::Associations::HasManyAssociation do
  let(:association_name) { Faker::Lorem.word.to_sym }
  let(:defined_on) { double }
  let(:options) do
    { class_name: 'CapsuleCRM::SomeClass' }
  end

  describe '#macro' do
    subject { described_class.new(association_name, defined_on, options).macro }

    it 'should eql :has_many' do
      expect(subject).to eql(:has_many)
    end
  end

  describe '#defined_on' do
    subject do
      described_class.new(association_name, defined_on, options).defined_on
    end

    it 'should return the defined_on argument' do
      expect(subject).to eql(defined_on)
    end
  end

  describe '#proxy' do
    let(:association) do
      described_class.new(association_name, defined_on, options)
    end
    let(:parent) { double(id: Random.rand(1..10)) }

    context 'when a collection is not supplied' do
      subject { association.proxy(parent) }

      it 'should return a HasManyProxy' do
        expect(subject).to eql(['test'])
      end
    end

    context 'when a collection is supplied' do
      let(:name) { Faker::Lorem.word }

      context 'when the collection is an object' do
        let(:collection) { CapsuleCRM::SomeClass.new }

        subject { association.proxy(parent, collection) }

        it 'should return an array' do
          expect(subject).to be_a(Array)
        end

        it 'should contain the object passed to the collection' do
          expect(subject).to include(collection)
        end
      end

      context 'when the collection is a hash' do
        let(:collection) do
          { some_class: { name: name } }
        end
        subject { association.proxy(parent, collection) }

        it 'should return an array' do
          expect(subject).to be_a(Array)
        end

        it 'should contain a new instance of the "SomeClass"' do
          expect(subject.first).to be_a(CapsuleCRM::SomeClass)
        end

        it 'should set the "SomeClass" instance attributes' do
          expect(subject.first.name).to eql(name)
        end
      end

      context 'when the collection is an array' do
        let(:collection) { [CapsuleCRM::SomeClass.new(name: name)] }
        subject { association.proxy(parent, collection) }

        it 'should return the supplied array' do
          expect(subject).to eql(collection)
        end
      end
    end
  end
end
