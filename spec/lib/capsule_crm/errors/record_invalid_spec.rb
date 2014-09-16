require 'spec_helper'

describe CapsuleCRM::Errors::RecordInvalid do
  let(:errors) { double('errors', full_messages: full_messages) }
  let(:full_messages) do
    ["Record can't be squishy", "Record can't be pink"]
  end
  let(:record) { double('Record', errors: errors) }

  subject { described_class.new(record) }

  describe '#to_s' do
    it 'should return the full messages joined by ,' do
      expect(subject.to_s).to eql(full_messages.join(', '))
    end
  end

  describe '#record' do
    it 'should be accessible' do
      expect(subject.record).to eql(record)
    end
  end
end
