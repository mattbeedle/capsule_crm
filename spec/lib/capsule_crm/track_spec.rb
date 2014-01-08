require 'spec_helper'

describe CapsuleCRM::Track do
  before { configure }

  describe 'validations' do
    it { should validate_numericality_of(:id) }
  end

  describe '.all' do
    before do
      stub_request(:get, /\/api\/tracks$/).
        to_return(body: File.read('spec/support/tracks.json'))
    end

    subject { CapsuleCRM::Track.all }

    it { expect(subject).to be_a(Array) }
    it { expect(subject.length).to eql(2) }
    it { expect(subject.first).to be_a(CapsuleCRM::Track) }
    it { expect(subject.first.description).to eql('Sales follow up') }
    it { expect(subject.first.capture_rule).to eql('OPPORTUNITY') }
    it { expect(subject.first.id).to eql(1) }
  end
end
