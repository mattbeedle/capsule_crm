require 'spec_helper'

describe CapsuleCRM::History do
  before { configure }

  it { should validate_presence_of(:note) }

  describe '.create' do
    pending
  end

  describe '.create!' do
    pending
  end

  describe '#update_attributes' do
    context 'when the history is valid' do
      subject do
        CapsuleCRM::History.new(note: Faker::Lorem.paragraph, id: 2)
      end

      before do
        stub_request(:put, /api\/history\/2$/).to_return(status: 200)
        subject.update_attributes note: 'changed note text'
      end

      it { subject.note.should eql('changed note text') }

      it { should be_persisted }
    end

    context 'when the history is not valid' do
      subject do
        CapsuleCRM::History.new(id: 2)
      end

      before { subject.update_attributes subject: Faker::Lorem.sentence }

      it { subject.should_not be_valid }
    end
  end

  describe '#update_attributes!' do
    context 'when it is valid' do
      subject do
        CapsuleCRM::History.new(note: Faker::Lorem.paragraph, id: 3)
      end

      before do
        stub_request(:put, /api\/history\/3$/).to_return(status: 200)
        subject.update_attributes! note: 'some new note'
      end

      it { subject.note.should eql('some new note') }

      it { should be_persisted }
    end

    context 'when it is not valid' do
      subject { CapsuleCRM::History.new(id: 3) }

      it do
        expect { subject.update_attributes! subject: 'test' }.
          to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#save' do
    pending
  end

  describe '#save!' do
    pending
  end

  describe '#new_record?' do
    pending
  end

  describe '#persisted?' do
    pending
  end

  describe '#to_capsule_json' do
    pending
  end
end
