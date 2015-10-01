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

    it { is_expected.to validate_numericality_of(:id) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:milestone) }
    it { is_expected.to validate_presence_of(:party) }
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

    it { is_expected.to be_a(Array) }

    it { expect(subject.length).to eql(1) }
  end

  describe '#milestone=' do
    context 'when it receives a milestone name' do
      subject { CapsuleCRM::Opportunity.new(milestone: 'Bid') }

      it { expect(subject.milestone).to be_a(CapsuleCRM::Milestone) }

      it { expect(subject.milestone_id).not_to be_blank }
    end

    context 'when it receives a milestone object' do
      let(:milestone) { CapsuleCRM::Milestone.all.first }

      subject { CapsuleCRM::Opportunity.new(milestone: milestone) }

      it { expect(subject.milestone).to be_a(CapsuleCRM::Milestone) }

      it { expect(subject.milestone_id).not_to be_blank }
    end
  end

  describe '#party=' do
    let(:opportunity) { Fabricate.build(:opportunity, party: nil) }

    let(:person) { CapsuleCRM::Person.new(id: 2) }

    before { opportunity.party= person }

    it 'should set the party_id' do
      expect(opportunity.party_id).to eql(2)
    end

    it 'should set the party' do
      expect(opportunity.party).to eql(person)
    end
  end

  describe '#party' do
    let(:person) { CapsuleCRM::Person.new(id: 1) }

    let(:organization) { CapsuleCRM::Organization.new(id: 2) }

    let(:opportunity) { Fabricate.build(:opportunity, party: nil) }

    context 'when the party is set' do
      context 'when the party is a person' do
        before { opportunity.party = person }

        it { expect(opportunity.party).to eql(person) }
      end

      context 'when the party is an organization' do
        before { opportunity.party = organization }

        it { expect(opportunity.party).to eql(organization) }
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
          expect(opportunity.party).to be_a(CapsuleCRM::Person)
        end

        it { expect(opportunity.party.id).to eql(opportunity.party_id) }
      end

      context 'when the party is an opportunity' do
        before do
          stub_request(:get, /.*/).
            to_return(body: File.read('spec/support/organisation.json'))
          opportunity.party_id = organization.id
        end

        it { expect(opportunity.party).to be_a(CapsuleCRM::Organization) }

        it { expect(opportunity.party.id).to eql(opportunity.party_id) }
      end
    end

    context 'when the party_id is nil' do
      it { expect(opportunity.party).to be_nil }
    end
  end

  describe '#to_capsule_json' do
    let(:opportunity) do
      Fabricate.build(:opportunity,
        value: 23.0,
        currency: 'USD',
        probability: 50.0
      )
    end

    subject {opportunity.to_capsule_json['opportunity']}

    it { is_expected.to have_key('name') }
    it { is_expected.to have_key('milestoneId') }
    it { is_expected.to have_key('partyId') }
    it { is_expected.to have_key('value') }
    it { is_expected.to have_key('currency') }

    it { is_expected.not_to have_key('probability')}
    it { is_expected.not_to have_key('trackId')}
  end

  describe '.deleted' do
    before do
      stub_request(:get, /.*/).
        to_return(body: File.read('spec/support/deleted_opportunities.json'))
    end

    subject { CapsuleCRM::Opportunity.deleted(1.week.ago) }

    it { is_expected.to be_a(Array) }

    it { expect(subject.length).to eql(2) }
  end
end
