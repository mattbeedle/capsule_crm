require 'spec_helper'

class SerializableTest
  include Virtus
  include CapsuleCRM::Associations

  attribute :id, Integer
  attribute :name
  attribute :description
  attribute :something, Date
end

describe CapsuleCRM::Serializer do
  describe '#serialize' do
    let(:options) do
      {}
    end
    let(:serializer) { described_class.new(object, options) }
    let(:object) do
      SerializableTest.new(
        id: Random.rand(1..10), name: Faker::Lorem.word,
        description: Faker::Lorem.word
      )
    end
    subject { serializer.serialize }

    context 'without an options' do
      it 'should not include the ID' do
        expect(subject['serializabletest'].keys).not_to include('id')
      end
    end

    context 'when include_root is false' do
      before do
        options.merge!(include_root: false)
      end

      it 'should not include the root' do
        expect(subject).to eql({
          'name' => object.name, 'description' => object.description
        })
      end
    end

    context 'when additional methods are supplied' do
      before do
        options.merge!(additional_methods: [:test])
        object.stub(:test).and_return(test_object)
      end
      let(:test_object) { double(to_capsule_json: { foo: :bar }) }

      it 'should serialize the additional methods' do
        expect(subject['serializabletest']['test']).to eql({ foo: :bar })
      end
    end

    context 'when excluded keys are supplied' do
      before do
        options.merge!(excluded_keys: [:description])
      end

      it 'should not include the excluded keys in the output' do
        expect(subject['serializabletest'].keys).not_to include('description')
      end
    end

    context 'when are root element name is supplied' do
      before do
        options.merge!(root: 'whatever')
      end

      it 'should use the root option as the root key' do
        expect(subject.keys.first).to eql('whatever')
      end
    end

    context 'when there are belongs to associations' do
      before do
        SerializableTest.send(
          :belongs_to, :person, class_name: CapsuleCRM::Person
        )
        object.person = person
      end
      let(:person) { double('CapsuleCRM::Person', id: Random.rand(1..10)) }

      context 'without a serializable key' do
        it 'should include the person id' do
          expect(subject['serializabletest']['personId']).to eql(person.id)
        end
      end

      context 'with a serializable key' do
        before do
          SerializableTest.send(
            :belongs_to, :person, class_name: CapsuleCRM::Person,
            serializable_key: 'monkeys'
          )
        end

        it 'should include the person id using the serializable key' do
          expect(subject['serializabletest']['monkeys']).to eql(person.id)
        end
      end
    end

    context 'when there are dates' do
      before { object.something = Date.today }

      it 'should format the dates in :db format' do
        expect(subject['serializabletest']['something']).
          to eql(Date.today.to_s(:db))
      end
    end
  end
end
