require 'spec_helper'

describe CapsuleCRM::History do
  before { configure }

  it { should validate_presence_of(:note) }

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
    pending
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
    pending
  end
end
