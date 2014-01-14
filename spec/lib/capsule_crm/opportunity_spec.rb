require 'spec_helper'

describe CapsuleCRM::Opportunity do
  before { configure }

  before do
    stub_request(:get, /\/api\/opportunity\/milestones$/).
      to_return(body: File.read('spec/support/all_milestones.json'))
  end

  before do
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
  end

  it_behaves_like 'persistable', 'https://sample.capsulecrm.com/api/opportunity/59', 59 do
    let(:attributes) do
      Fabricate.attributes_for(:opportunity).merge(party: party)
    end
    let(:party) { Fabricate.build(:person, id: Random.rand(1..10)) }
  end

  it_behaves_like 'deletable'

  it_behaves_like 'listable', '/opportunity', 'opportunities', 1

  it_behaves_like 'findable', '/api/opportunity/1', 1, 'opportunity' do
    let(:attributes) do
      {
        value: 500.0, id: 43, duration_basis: 'DAY', milestone_id: 2,
        duration: 10, currency: 'GBP',
        description: 'Scope and design web site shopping cart'
      }
    end
  end

  describe 'validations' do
    subject { described_class.new }

    it { should validate_numericality_of(:id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:milestone) }
    it { should validate_presence_of(:party) }
  end

  describe '._for_track' do
    let(:track) { CapsuleCRM::Track.new }

    it 'should raise a not implemented error' do
      expect { CapsuleCRM::Opportunity._for_track(track) }.
        to raise_error(NotImplementedError)
    end
  end

  describe '#tasks' do
    let(:opportunity) { Fabricate.build(:opportunity, id: 5) }

    before do
      stub_request(:get, /\/api\/tasks$/).
        to_return(body: File.read('spec/support/all_tasks.json'))
    end

    subject { opportunity.tasks }

    it { should be_a(Array) }

    it { subject.length.should eql(1) }
  end

  describe '#milestone=' do
    context 'when it receives a milestone name' do
      subject { CapsuleCRM::Opportunity.new(milestone: 'Bid') }

      it { subject.milestone.should be_a(CapsuleCRM::Milestone) }

      it { subject.milestone_id.should_not be_blank }
    end

    context 'when it receives a milestone object' do
      let(:milestone) { CapsuleCRM::Milestone.all.first }

      subject { CapsuleCRM::Opportunity.new(milestone: milestone) }

      it { subject.milestone.should be_a(CapsuleCRM::Milestone) }

      it { subject.milestone_id.should_not be_blank }
    end
  end

  describe '#party=' do
    let(:opportunity) { Fabricate.build(:opportunity, party: nil) }

    let(:person) { CapsuleCRM::Person.new(id: 2) }

    before { opportunity.party= person }

    it 'should set the party_id' do
      opportunity.party_id.should eql(2)
    end

    it 'should set the party' do
      opportunity.party.should eql(person)
    end
  end

  describe '#party' do
    let(:person) { CapsuleCRM::Person.new(id: 1) }

    let(:organization) { CapsuleCRM::Organization.new(id: 2) }

    let(:opportunity) { Fabricate.build(:opportunity, party: nil) }

    context 'when the party is set' do
      context 'when the party is a person' do
        before { opportunity.party = person }

        it { opportunity.party.should eql(person) }
      end

      context 'when the party is an organization' do
        before { opportunity.party = organization }

        it { opportunity.party.should eql(organization) }
      end
    end

    context 'when the party_id is set' do
      context 'when the party is a person' do
        before do
          stub_request(:get, /.*/).
            to_return(body: File.read('spec/support/person.json'))
          opportunity.party_id = person.id
        end

        it 'should return the party' do
          opportunity.party.should be_a(CapsuleCRM::Person)
        end

        it { opportunity.party.id.should eql(opportunity.party_id) }
      end

      context 'when the party is an opportunity' do
        before do
          stub_request(:get, /.*/).
            to_return(body: File.read('spec/support/organisation.json'))
          opportunity.party_id = organization.id
        end

        it { opportunity.party.should be_a(CapsuleCRM::Organization) }

        it { opportunity.party.id.should eql(opportunity.party_id) }
      end
    end

    context 'when the party_id is nil' do
      it { opportunity.party.should be_nil }
    end
  end

  describe '.deleted' do
    before do
      stub_request(:get, /.*/).
        to_return(body: File.read('spec/support/deleted_opportunities.json'))
    end

    subject { CapsuleCRM::Opportunity.deleted(1.week.ago) }

    it { should be_a(Array) }

    it { subject.length.should eql(2) }
  end
end
