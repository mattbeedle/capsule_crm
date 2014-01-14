require 'spec_helper'

class BelongsToTest
  include Virtus
  include CapsuleCRM::Associations

  belongs_to :person
end

describe CapsuleCRM::Associations::BelongsTo do
  describe '.belongs_to' do
    subject { BelongsToTest.new }

    it 'should create a foreign key getter' do
      expect(subject).to respond_to(:person_id)
    end

    it 'should create a foreign key setter' do
      expect(subject).to respond_to(:person_id=)
    end

    it 'should create a class level finder method' do
      expect(subject.class).to respond_to(:_for_person)
    end

    it 'should create an association setter method' do
      expect(subject).to respond_to(:person=)
    end

    it 'should create an association getter method' do
      expect(subject).to respond_to(:person)
    end
  end
end
