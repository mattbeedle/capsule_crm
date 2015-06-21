require 'spec_helper'

describe CapsuleCRM::History do
  before { configure }

  before do
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
    stub_request(:get, /\/api\/opportunity\/milestones$/).
      to_return(body: File.read('spec/support/all_milestones.json'))
  end

  it_behaves_like 'persistable', 'https://sample.capsulecrm.com/api/history/205', 205 do
    let(:attributes) { Fabricate.attributes_for(:history).merge(party: party) }
    let(:party) { Fabricate.build(:person, id: Random.rand(1..10)) }
  end

  it_behaves_like 'deletable'

  describe 'validations' do
    subject { described_class.new }

    it { should validate_numericality_of(:id) }
    it { should validate_presence_of(:note) }
    it { should validate_presence_of(:case) }
    it { should validate_presence_of(:party) }
    it { should validate_presence_of(:opportunity) }

    context 'when it belongs to a case' do
      before do
        subject.case = CapsuleCRM::Case.new(id: Random.rand(1..10))
      end

      it { should_not validate_presence_of(:party) }
      it { should_not validate_presence_of(:opportunity) }
    end

    context 'when it belongs to a party' do
      before do
        subject.party = CapsuleCRM::Party.new(id: Random.rand(1..10))
      end

      it { should_not validate_presence_of(:case) }
      it { should_not validate_presence_of(:opportunity) }
    end

    context 'when it belongs to an opportunity' do
      before do
        subject.opportunity =
          CapsuleCRM::Opportunity.new(id: Random.rand(1..10))
      end

      it { should_not validate_presence_of(:party) }
      it { should_not validate_presence_of(:case) }
    end
  end

  describe '_.for_party' do
    let(:party) { Fabricate.build(:person, id: 1) }

    subject { CapsuleCRM::History._for_party(party.id) }

    context 'when there are some history items' do
      before do
        stub_request(:get, /\/api\/party\/#{party.id}\/history$/).
          to_return(body: File.read('spec/support/all_history.json'))
      end

      it { should be_a(Array) }

      it do
        subject.all? { |item| item.is_a?(CapsuleCRM::History) }.should eql(true)
      end
    end

    context 'when there are no history items' do
      before do
        stub_request(:get, /\/api\/party\/#{party.id}\/history$/).
          to_return(body: File.read('spec/support/no_history.json'))
      end

      it { should be_blank }
    end
  end

  describe '._for_case' do
    let(:kase) { Fabricate.build(:case, id: 1) }

    subject { CapsuleCRM::History._for_case(kase.id) }

    context 'when there are some history items' do
      before do
        stub_request(:get, /\/api\/kase\/#{kase.id}\/history$/).
          to_return(body: File.read('spec/support/all_history.json'))
      end

      it { should be_a(Array) }

      it do
        subject.all? { |item| item.is_a?(CapsuleCRM::History) }.should eql(true)
      end
    end

    context 'when there are no history items' do
      before do
        stub_request(:get, /\/api\/kase\/#{kase.id}\/history$/).
          to_return(body: File.read('spec/support/no_history.json'))
      end

      it { should be_blank }
    end
  end

  describe '._for_opportunity' do
    let(:opportunity) { Fabricate.build(:opportunity, id: 1) }

    subject { CapsuleCRM::History._for_opportunity(opportunity.id) }

    context 'when there are some history items' do
      before do
        stub_request(:get, /\/api\/opportunity\/#{opportunity.id}\/history$/).
          to_return(body: File.read('spec/support/all_history.json'))
      end

      it { should be_a(Array) }

      it do
        subject.all? { |item| item.is_a?(CapsuleCRM::History) }.should eql(true)
      end
    end

    context 'when there are no history items' do
      before do
        stub_request(:get, /\/api\/opportunity\/#{opportunity.id}\/history$/).
          to_return(body: File.read('spec/support/no_history.json'))
      end

      it { should be_blank }
    end
  end

  describe '.find' do
    let(:first_attachment) { subject.attachments.first }
    let(:first_participant) { subject.participants.first }
    before do
      stub_request(:get, /\/api\/history\/100$/).
        to_return(body: File.read('spec/support/history.json'))
      stub_request(:get, /\/api\/users$/).
        to_return(body: File.read('spec/support/all_users.json'))
    end
    subject { CapsuleCRM::History.find(100) }

    it 'type is note' do
      expect(subject.type).to eql('Note')
    end

    it 'creator is a CapsuleCRM::User' do
      expect(subject.creator).to be_a(CapsuleCRM::User)
    end

    it 'entry date is not blank' do
      expect(subject.entry_date).not_to be_blank
    end

    it 'subject is not blank' do
      expect(subject.subject).not_to be_blank
    end

    it 'note is not blank' do
      expect(subject.note).not_to be_blank
    end

    it 'attachments is an array' do
      expect(subject.attachments).to be_a(Array)
    end

    it 'attachments array contains CapsuleCRM::Attachment objects' do
      expect(first_attachment).to be_a(CapsuleCRM::Attachment)
    end

    it 'has the correct attachment filename' do
      expect(first_attachment.filename).to eql('latin.doc')
    end

    it 'has an array of participants' do
      expect(subject.participants).to be_a(Array)
    end

    it 'has CapsuleCRM::Participant objects inside the participants array' do
      expect(first_participant).to be_a(CapsuleCRM::Participant)
    end

    it 'has the correct participant names' do
      expect(first_participant.name).to eql('Matt Beedle')
    end

    context 'when it belongs to a party' do
      before do
        stub_request(:get, /\/api\/party\/1$/).
          to_return(body: File.read('spec/support/person.json'))
      end

      it 'has a party_id' do
        expect(subject.party_id).not_to be_blank
      end

      it 'has a party' do
        expect(subject.party).not_to be_blank
      end
    end

    context 'when it belongs to a case' do
      before do
        stub_request(:get, /\/api\/kase\/5$/).
          to_return(body: File.read('spec/support/case.json'))
      end

      it 'has a case_id' do
        expect(subject.case_id).not_to be_blank
      end

      it 'has a case' do
        expect(subject.case).not_to be_blank
      end
    end

    context 'when it belongs to an opportunity' do
      before do
        stub_request(:get, /\/api\/opportunity\/2$/).
          to_return(body: File.read('spec/support/opportunity.json'))
      end

      it 'has an opportunity_id' do
        expect(subject.opportunity_id).not_to be_blank
      end

      it 'has an opportunity' do
        expect(subject.opportunity).not_to be_blank
      end
    end
  end

  describe '#creator=' do
    let(:history) { CapsuleCRM::History.new }
    subject { history }

    context 'when a String is supplied' do
      before do
        stub_request(:get, /\/api\/users$/).
          to_return(body: File.read('spec/support/all_users.json'))
      end

      context 'when the user exists' do
        before { history.creator = 'a.user' }

        it 'has a creator' do
          expect(subject.creator).to be_a(CapsuleCRM::User)
        end
      end

      context 'when the user does not exist' do
        before { history.creator = 'asdfadsfdsaf' }

        it 'has no creator' do
          expect(subject.creator).to be_blank
        end
      end
    end

    context 'when a CapsuleCRM::Person is supplied' do
      let(:user) { CapsuleCRM::User.new }
      before { history.creator = user }

      it 'has a creator' do
        expect(subject.creator).to eql(user)
      end
    end
  end

  describe '#to_capsule_json' do
    let(:creator) { CapsuleCRM::User.new(username: Faker::Name.name) }
    let(:history) do
      CapsuleCRM::History.new(
        type: 'Note', entry_date: Time.now, creator: creator,
        subject: Faker::Lorem.sentence, note: Faker::Lorem.paragraph,
        participants: [participant]
      )
    end
    let(:participant) do
      CapsuleCRM::Participant.new(
        name: Faker::Name.name, email_address: Faker::Internet.email,
        role: 'TO'
      )
    end
    let(:participants_json) { subject[:historyItem]['participants'] }
    subject { history.to_capsule_json }

    it 'has historyItem as the first key' do
      expect(subject.keys.first).to eql('historyItem')
    end

    it 'has the correct history item entry date' do
      expect(subject['historyItem']['entryDate']).
        to eql(history.entry_date.utc.strftime('%Y-%m-%dT%H:%M:%SZ'))
    end

    it 'has the correct history item creator' do
      expect(subject['historyItem']['creator']).to eql(creator.username)
    end

    it 'has the correct history item note' do
      expect(subject['historyItem']['note']).to eql(history.note)
    end
  end
end
