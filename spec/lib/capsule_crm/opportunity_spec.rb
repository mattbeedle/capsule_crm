require 'spec_helper'

describe CapsuleCRM::Opportunity do
  before { configure }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:milestone_id) }

  it { should validate_presence_of(:milestone) }

  context 'when milestone_id is set' do
    subject { CapsuleCRM::Opportunity.new(milestone_id: 1) }

    it { should_not validate_presence_of(:milestone) }
  end

  context 'when milestone is set' do
    subject { CapsuleCRM::Opportunity.new(milestone: 'a') }

    it { should_not validate_presence_of(:milestone_id) }
  end

  describe '.all' do
    before do
      stub_request(:get, /\/api\/opportunity$/).
        to_return(body: File.read('spec/support/all_opportunities.json'))
    end

    subject { CapsuleCRM::Opportunity.all }

    it { should be_a(Array) }

    it { subject.length.should eql(1) }

    it 'should only contain people' do
      subject.all? { |item| item.is_a?(CapsuleCRM::Opportunity) }.should be_true
    end
  end

  describe '.find' do
    before do
      stub_request(:get, /.*/).
        to_return(body: File.read('spec/support/opportunity.json'))
    end

    subject { CapsuleCRM::Opportunity.find(1) }

    it { should be_a(CapsuleCRM::Opportunity) }

    it { subject.value.should eql(500.0) }

    it { subject.id.should eql(43) }

    it { subject.duration_basis.should eql('DAY') }

    it { subject.milestone_id.should eql(2) }

    it { subject.duration.should eql(10) }

    it { subject.currency.should eql('GBP') }

    it do
      subject.description.should eql('Scope and design web site shopping cart')
    end

    it { subject.name.should eql('Consulting') }

    it { subject.owner.should eql('a.user') }

    it { subject.milestone.should eql('Bid') }

    it { subject.probability.should eql(50.0) }

    it do
      subject.expected_close_date.should eql(Date.parse('2012-09-30T00:00:00Z'))
    end

    it { subject.party_id.should eql(2) }
  end

  describe '#attributes=' do
    let(:opportunity) { CapsuleCRM::Opportunity.new }

    before do
      opportunity.attributes = { partyId: '1', milestoneId: '3' }
    end

    it { opportunity.party_id.should eql(1) }

    it { opportunity.milestone_id.should eql(3) }
  end
end
