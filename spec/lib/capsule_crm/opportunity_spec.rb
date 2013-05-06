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

  describe '.create' do
    context 'when the opportunity is valid' do
      before do
        stub_request(:post, request_path).to_return(headers: {
          'Location' => 'https://sample.capsulecrm.com/api/opportunity/59'
        })
      end

      let(:request_path) do
        [
          'https://1234:@company.capsulecrm.com/api/party/',
          opportunity_attributes[:party_id],
          '/opportunity'
        ].join
      end

      let(:opportunity_attributes) { Fabricate.attributes_for(:opportunity) }

      subject do
        CapsuleCRM::Opportunity.create opportunity_attributes
      end

      it { should be_a(CapsuleCRM::Opportunity) }

      it { should be_persisted }

      it { subject.id.should eql(59) }
    end

    context 'when the opportunity is not valid' do
      subject { CapsuleCRM::Opportunity.create }

      it { subject.errors.should_not be_blank }
    end
  end

  describe '.create!' do
    context 'when the opportunity is valid' do
      before do
        stub_request(:post, /.*/).to_return(headers: {
          'Location' => 'https://sample.capsulecrm.com/api/opportunity/71'
        })
      end

      subject do
        CapsuleCRM::Opportunity.create Fabricate.attributes_for(:opportunity)
      end

      it { should be_a(CapsuleCRM::Opportunity) }

      it { should be_persisted }

      it { subject.id.should eql(71) }
    end

    context 'when the opportunity is not valid' do
      it do
        expect { CapsuleCRM::Opportunity.create! }.
          to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#update_attributes' do
    context 'when the opportunity is valid' do
      before do
        stub_request(:put, /.*/).to_return(status: 200)
      end

      let(:opportunity) { CapsuleCRM::Opportunity.new(id: 1) }

      before { opportunity.update_attributes name: 'renamed' }

      it { opportunity.name.should eql('renamed') }

      it { opportunity.id.should eql(1) }
    end

    context 'when the opportunity is not valid' do
      let(:opportunity) { CapsuleCRM::Opportunity.new(id: 1) }

      before { opportunity.update_attributes }

      it { opportunity.should_not be_valid }

      it { opportunity.errors.should_not be_blank }
    end
  end

  describe '#update_attributes!' do

    let(:opportunity) { CapsuleCRM::Opportunity.new(id: 1) }

    context 'when the opportunity is valid' do
      before do
        stub_request(:put, /.*/).to_return(status: 200)
      end

      before { opportunity.update_attributes name: 'A New Name' }

      it { opportunity.name.should eql('A New Name') }

      it { opportunity.id.should eql(1) }
    end

    context 'when the opportunity is not valid' do
      it do
        expect { opportunity.update_attributes! }.
          to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#save' do
    context 'when the opportunity is a new record' do
      before do
        stub_request(:post, /.*/).to_return(headers: {
          'Location' => 'https://sample.capsulecrm.com/api/party/100'
        }, status: 200)
      end

      let(:opportunity) do
        Fabricate.build(:opportunity)
      end

      before { opportunity.save }

      it { opportunity.name.should eql('Test') }

      it { opportunity.milestone_id.should eql(1) }

      it { opportunity.should be_persisted }
    end
  end

  describe '#save!' do
    context 'when the opportunity is a new record' do
      context 'when the opportunity is valid' do
        before do
          stub_request(:post, /.*/).to_return(headers: {
            'Location' => 'https://sample.capsulecrm.com/api/party/100',
          }, status: 200)
        end

        let(:opportunity) do
          Fabricate.build(:opportunity)
        end

        before { opportunity.save! }

        it { opportunity.should be_persisted }
      end

      context 'when the opportunity is not valid' do
        let(:opportunity) { CapsuleCRM::Opportunity.new }

        it do
          expect { opportunity.save! }.
            to raise_error(CapsuleCRM::Errors::RecordInvalid)
        end
      end
    end

    context 'when the opportunity is not a new record' do
      context 'when the opportunity is not valid' do

        let(:opportunity) { CapsuleCRM::Opportunity.new(id: 1) }

        it do
          expect { opportunity.save! }.
            to raise_exception(CapsuleCRM::Errors::RecordInvalid)
        end
      end
    end
  end

  describe '#new_record?' do
    context 'when the opportunity is a new record' do
      let(:opportunity) { CapsuleCRM::Opportunity.new }

      subject { opportunity.new_record? }

      it { should be_true }
    end

    context 'when the opportunity is not a new record' do
      let(:opportunity) { CapsuleCRM::Opportunity.new(id: 1) }

      subject { opportunity.new_record? }

      it { should be_false }
    end
  end

  describe '#persisted?' do
    context 'when the opportunity is persisted' do
      let(:opportunity) { CapsuleCRM::Opportunity.new(id: 1) }

      subject { opportunity.persisted? }

      it { should be_true }
    end

    context 'when the opportunity is not persisted' do
      let(:opportunity) { CapsuleCRM::Opportunity.new }

      subject { opportunity.persisted? }

      it { should be_false }
    end
  end

  describe '.init_collection' do
    subject do
      CapsuleCRM::Opportunity.init_collection(
        JSON.parse(
          File.read('spec/support/all_opportunities.json')
        )['opportunities']['opportunity']
      )
    end

    it { should be_a(Array) }

    it { subject.length.should eql(1) }

    it do
      subject.all? { |item| item.is_a?(CapsuleCRM::Opportunity) }.should be_true
    end
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
