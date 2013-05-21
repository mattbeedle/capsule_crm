require 'spec_helper'

describe CapsuleCRM::History do
  before { configure }

  it { should validate_presence_of(:note) }

  describe 'find' do
    before do
      stub_request(:get, /\/api\/history\/100$/).
        to_return(body: File.read('spec/support/history.json'))
      stub_request(:get, /\/api\/users$/).
        to_return(body: File.read('spec/support/all_users.json'))
    end

    subject { CapsuleCRM::History.find(100) }

    it { subject.type.should eql('Note') }

    it { subject.creator.should be_a(CapsuleCRM::User) }

    it { subject.entry_date.should_not be_blank }

    it { subject.subject.should_not be_blank }

    it { subject.note.should_not be_blank }

    it { subject.attachments.should be_a(Array) }

    it { subject.attachments.first.should be_a(CapsuleCRM::Attachment) }

    it { subject.attachments.first.filename.should eql('latin.doc') }

    it { subject.participants.should be_a(Array) }

    it { subject.participants.first.should be_a(CapsuleCRM::Participant) }

    it { subject.participants.first.name.should eql('Matt Beedle') }

    context 'when it belongs to a party' do
      before do
        stub_request(:get, /\/api\/party\/1$/).
          to_return(body: File.read('spec/support/person.json'))
      end

      it { subject.party_id.should_not be_blank }

      it { subject.party.should_not be_blank }
    end

    context 'when it belongs to a case' do
      before do
        stub_request(:get, /\/api\/kase\/5$/).
          to_return(body: File.read('spec/support/case.json'))
      end

      it { subject.case_id.should_not be_blank }

      it { subject.kase.should_not be_blank }
    end

    context 'when it belongs to an opportunity' do
      before do
        stub_request(:get, /\/api\/opportunity\/2$/).
          to_return(body: File.read('spec/support/opportunity.json'))
      end

      it { subject.opportunity_id.should_not be_blank }

      it { subject.opportunity.should_not be_blank }
    end
  end

  describe '#creator=' do
    let(:history) { CapsuleCRM::History.new }

    context 'when a String is supplied' do
      before do
        stub_request(:get, /\/api\/users$/).
          to_return(body: File.read('spec/support/all_users.json'))
      end

      context 'when the user exists' do
        before { history.creator = 'a.user' }

        it { history.creator.should be_a(CapsuleCRM::User) }
      end

      context 'when the user does not exist' do
        before { history.creator = 'asdfadsfdsaf' }

        it { history.creator.should be_blank }
      end
    end

    context 'when a CapsuleCRM::Person is supplied' do
      let(:user) { CapsuleCRM::User.new }

      before { history.creator = user }

      it { history.creator.should eql(user) }
    end
  end

  describe '.create' do
    context 'when it belongs to a party' do
      let(:person) { Fabricate.build(:person, id: 1) }

      subject do
        CapsuleCRM::History.create(
          note: Faker::Lorem.paragraph, party: person
        )
      end

      let(:location) do
        "https://sample.capsulecrm.com/api/party/#{person.id}/history/101"
      end

      before do
        stub_request(:post, /\/api\/party\/#{person.id}\/history$/).
          to_return(headers: { 'Location' => location})
      end

      it { subject.id.should eql(101) }
    end

    context 'when it belongs to a kase' do
      let(:kase) { Fabricate.build(:case, id: 2) }

      let(:location) do
        "https://sample.capsulecrm.com/api/kase/#{kase.id}/history/10"
      end

      subject do
        CapsuleCRM::History.create(note: Faker::Lorem.paragraph, kase: kase)
      end

      before do
        stub_request(:post, /\/api\/kase\/#{kase.id}\/history$/).
          to_return(headers: { 'Location' => location })
      end

      it { subject.id.should eql(10) }
    end

    context 'when it belongs to an opportunity' do
      let(:opportunity) { Fabricate.build(:opportunity, id: 1) }

      subject do
        CapsuleCRM::History.create(
          note: Faker::Lorem.paragraph, opportunity: opportunity
        )
      end

      let(:location) do
        [
          'https://sample.capsulecrm.com/api/opportunity/',
          opportunity.id, '/history/9'
        ].join
      end

      before do
        stub_request(:post, /\/api\/opportunity\/#{opportunity.id}\/history$/).
          to_return(headers: { 'Location' => location })
      end

      it { subject.id.should eql(9) }
    end

    context 'when it is invalid' do
      subject { CapsuleCRM::History.create }

      it { should_not be_valid }
    end
  end

  describe '.create!' do
    context 'when it belongs to a party' do
      let(:person) { Fabricate.build(:person, id: 1) }

      subject do
        CapsuleCRM::History.create!(
          note: Faker::Lorem.paragraph, party: person
        )
      end

      let(:location) do
        "https://sample.capsulecrm.com/api/party/#{person.id}/history/101"
      end

      before do
        stub_request(:post, /\/api\/party\/#{person.id}\/history$/).
          to_return(headers: { 'Location' => location})
      end

      it { subject.id.should eql(101) }
    end

    context 'when it belongs to a kase' do
      let(:kase) { Fabricate.build(:case, id: 2) }

      let(:location) do
        "https://sample.capsulecrm.com/api/kase/#{kase.id}/history/10"
      end

      subject do
        CapsuleCRM::History.create!(note: Faker::Lorem.paragraph, kase: kase)
      end

      before do
        stub_request(:post, /\/api\/kase\/#{kase.id}\/history$/).
          to_return(headers: { 'Location' => location })
      end

      it { subject.id.should eql(10) }
    end

    context 'when it belongs to an opportunity' do
      let(:opportunity) { Fabricate.build(:opportunity, id: 1) }

      subject do
        CapsuleCRM::History.create!(
          note: Faker::Lorem.paragraph, opportunity: opportunity
        )
      end

      let(:location) do
        [
          'https://sample.capsulecrm.com/api/opportunity/',
          opportunity.id, '/history/9'
        ].join
      end

      before do
        stub_request(:post, /\/api\/opportunity\/#{opportunity.id}\/history$/).
          to_return(headers: { 'Location' => location })
      end

      it { subject.id.should eql(9) }
    end

    context 'when it is invalid' do
      it do
        expect { CapsuleCRM::History.create! }.
          to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#update_attributes' do
    context 'when the history is valid' do
      subject { Fabricate(:history, id: 2, party: Fabricate.build(:person)) }

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
      subject { Fabricate(:history, id: 3, party: Fabricate.build(:case)) }

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
    context 'when it is a new record' do
      let(:history) { Fabricate.build(:history) }

      context 'when it belongs to a party' do
        let(:party) { Fabricate.build(:organization, id: 2) }

        let(:location) do
          "https://sample.capsulecrm.com/api/party/#{party.id}/history/101"
        end

        before do
          history.party = party
          stub_request(:post, /\/api\/party\/#{party.id}\/history$/).
            to_return(headers: { 'Location' => location })
          history.save
        end

        it { history.id.should eql(101) }

        it { history.should be_persisted }
      end

      context 'when it belongs to a kase' do
        let(:kase) { Fabricate.build(:case, id: 5) }

        let(:location) do
          "https://sample.capsulecrm.com/api/kase/#{kase.id}/history/10005"
        end

        before do
          history.kase = kase
          stub_request(:post, /\/api\/kase\/#{kase.id}\/history$/).
            to_return(headers: { 'Location' => location })
          history.save
        end

        it { history.id.should eql(10005) }

        it { history.should be_persisted }
      end

      context 'when it belongs to an opportunity' do
        let(:opportunity) { Fabricate.build(:opportunity, id: 3) }

        let(:location) do
          [
            'https://sample.capsulecrm.com/api/opportunity/',
            opportunity.id, '/history/101'
          ].join
        end

        before do
          history.opportunity = opportunity
          stub_request(
            :post, /\/api\/opportunity\/#{opportunity.id}\/history$/
          ).to_return(headers: { 'Location' => location })
          history.save
        end

        it { history.id.should eql(101) }

        it { history.should be_persisted }
      end
    end

    context 'when it is an existing record' do
      let(:history) do
        Fabricate.build(:history, party: Fabricate.build(:person), id: 10)
      end

      before do
        stub_request(:put, /\/api\/history\/#{history.id}$/).
          to_return(status: 200)
        history.save
      end

      it { history.should be_persisted }
    end
  end

  describe '#save!' do
    context 'when it is a new record' do
      context 'when it is invalid' do
        let(:history) { CapsuleCRM::History.new(id: 5) }

        it 'should raise an error' do
          expect { history.save! }.
            to raise_error(CapsuleCRM::Errors::RecordInvalid)
        end
      end

      let(:history) { Fabricate.build(:history) }

      context 'when it belongs to a party' do
        let(:party) { Fabricate.build(:organization, id: 2) }

        let(:location) do
          "https://sample.capsulecrm.com/api/party/#{party.id}/history/101"
        end

        before do
          history.party = party
          stub_request(:post, /\/api\/party\/#{party.id}\/history$/).
            to_return(headers: { 'Location' => location })
          history.save!
        end

        it { history.id.should eql(101) }

        it { history.should be_persisted }
      end

      context 'when it belongs to a kase' do
        let(:kase) { Fabricate.build(:case, id: 5) }

        let(:location) do
          "https://sample.capsulecrm.com/api/kase/#{kase.id}/history/10005"
        end

        before do
          history.kase = kase
          stub_request(:post, /\/api\/kase\/#{kase.id}\/history$/).
            to_return(headers: { 'Location' => location })
          history.save!
        end

        it { history.id.should eql(10005) }

        it { history.should be_persisted }
      end

      context 'when it belongs to an opportunity' do
        let(:opportunity) { Fabricate.build(:opportunity, id: 3) }

        let(:location) do
          [
            'https://sample.capsulecrm.com/api/opportunity/',
            opportunity.id, '/history/101'
          ].join
        end

        before do
          history.opportunity = opportunity
          stub_request(
            :post, /\/api\/opportunity\/#{opportunity.id}\/history$/
          ).to_return(headers: { 'Location' => location })
          history.save!
        end

        it { history.id.should eql(101) }

        it { history.should be_persisted }
      end
    end

    context 'when it is an existing record' do
      context 'when it is valid' do
        let(:history) do
          Fabricate.build(:history, party: Fabricate.build(:person), id: 10)
        end

        before do
          stub_request(:put, /\/api\/history\/#{history.id}$/).
            to_return(status: 200)
          history.save!
        end

        it { history.should be_persisted }
      end

      context 'when it is not valid' do
        let(:history) { CapsuleCRM::History.new(id: 1) }

        it 'should raise an error' do
          expect { history.save! }.
            to raise_error(CapsuleCRM::Errors::RecordInvalid)
        end
      end
    end
  end

  describe '#destroy' do
    let(:history) { Fabricate.build(:history, id: 19) }

    before do
      stub_request(:delete, /\/api\/history\/#{history.id}$/).
        to_return(status: 200)
      history.destroy
    end

    subject { history }

    it { should_not be_persisted }
  end

  describe '#new_record?' do
    context 'when the history item is a new record' do
      let(:history) { CapsuleCRM::History.new }

      subject { history.new_record? }

      it { should be_true }
    end

    context 'when the history item is not a new record' do
      let(:history) { CapsuleCRM::History.new(id: 1) }

      subject { history.new_record? }

      it { should be_false }
    end
  end

  describe '#persisted?' do
    context 'when the history item is persisted' do
      let(:history) { CapsuleCRM::History.new(id: 1) }

      subject { history.persisted? }

      it { should be_true }
    end

    context 'when the hitory item is not persisted' do
      let(:history) { CapsuleCRM::History.new }

      subject { history.persisted? }

      it { should be_false }
    end
  end

  describe '#to_capsule_json' do
    let(:creator) do
      Fabricate.build(
        :person, first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name
      )
    end

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

    subject { history.to_capsule_json }

    let(:participants_json) { subject[:historyItem]['participants'] }

    it { subject.keys.first.should eql(:historyItem) }

    it { subject[:historyItem]['entryDate'].should eql(history.entry_date) }

    it { subject[:historyItem]['creator'].should eql(creator.username) }

    it { subject[:historyItem]['note'].should eql(history.note) }

    it { subject[:historyItem].should have_key('note') }
  end
end
