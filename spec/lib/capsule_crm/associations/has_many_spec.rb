require 'spec_helper'

class HasManyTest
  include CapsuleCRM::Associations

  has_many :people
end

describe CapsuleCRM::Associations::HasMany do
  describe '#has_many' do
    subject { HasManyTest.new }

    it 'should create an accessor method' do
      expect(subject).to respond_to(:people)
    end

    it 'should create a setter method' do
      expect(subject).to respond_to(:people=)
    end
  end
end
