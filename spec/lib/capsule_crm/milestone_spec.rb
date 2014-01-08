require 'spec_helper'

describe CapsuleCRM::Milestone do
  before { configure }

  describe 'validations' do
    it { should validate_numericality_of(:id) }
  end

  describe '.all' do
    before do
      stub_request(:get, /\/api\/opportunity\/milestones$/).
        to_return(body: File.read('spec/support/milestones.json'))
    end

    subject { CapsuleCRM::Milestone.all }

    it { should be_a(Array) }

    it do
      subject.all? { |item| item.is_a?(CapsuleCRM::Milestone) }.should be_true
    end

    it do
      expect(subject.first.description).
        to eql('You have a potential buyer for your offering')
    end

    it { expect(subject.first.probability).to eql(10.0) }

    it { expect(subject.first.complete).to be_false }
  end
end
