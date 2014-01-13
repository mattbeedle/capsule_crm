require 'spec_helper'

describe CapsuleCRM::Opportunity do
  before { configure }

  before do
    stub_request(:get, /\/api\/opportunity\/milestones$/).
      to_return(body: File.read('spec/support/milestones.json'))
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
      stub_request(:get, /\/api\/opportunity\/1$/).
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

    it { subject.milestone.name.should eql('Bid') }

    it { subject.probability.should eql(50.0) }

    it do
      subject.expected_close_date.should eql(Date.parse('2012-09-30T00:00:00Z'))
    end

    it { subject.party_id.should eql(2) }
  end

  describe '#destroy' do
    let(:opportunity) do
      CapsuleCRM::Opportunity.new(id: 1)
    end

    before do
      stub_request(:delete, /.*/).to_return(status: 200)
      opportunity.destroy
    end

    it { opportunity.id.should be_blank }

    it { opportunity.should_not be_persisted }
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
