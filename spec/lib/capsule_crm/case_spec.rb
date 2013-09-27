require 'spec_helper'

describe CapsuleCRM::Case do
  before { configure }

  before do
    stub_request(:get, /\/api\/users$/).
      to_return(body: File.read('spec/support/all_users.json'))
  end

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:party) }

  describe '._for_track' do
    let(:track) { CapsuleCRM::Track.new }

    it do
      expect { CapsuleCRM::Case._for_track(track) }.
        to raise_error(NotImplementedError)
    end
  end

  describe '#tasks' do
    let(:kase) { Fabricate.build(:case, id: 3) }

    before do
      stub_request(:get, /\/api\/tasks$/).
        to_return(body: File.read('spec/support/all_tasks.json'))
    end

    subject { kase.tasks }

    it { should be_an(Array) }

    it { subject.length.should eql(1) }

    it { subject.first.detail.should eql('Go and get drunk') }
  end

  describe '.all' do
    before do
      stub_request(:get, 'https://1234:@company.capsulecrm.com/api/kase').
        to_return(body: File.read('spec/support/all_cases.json'))
    end

    subject { CapsuleCRM::Case.all }

    it { should be_a(Array) }

    it { subject.length.should eql(1) }

    it { subject.all? { |item| item.is_a?(CapsuleCRM::Case) }.should be_true }
  end

  describe '.find' do
    before do
      stub_request(:get, 'https://1234:@company.capsulecrm.com/api/kase/43').
        to_return(body: File.read('spec/support/case.json'))
    end

    subject { CapsuleCRM::Case.find(43) }

    it { should be_a(CapsuleCRM::Case) }

    it { subject.name.should eql('Consulting') }
  end

  describe '.create' do
    let(:request_uri) do
      'https://1234:@company.capsulecrm.com/api/party/1/kase'
    end

    let(:party) { CapsuleCRM::Person.new(id: 1, first_name: 'Matt') }

    context 'when the case is valid' do
      before do
        stub_request(:post, request_uri).to_return(
          headers: { 'Location' => 'https://sample.capsulecrm.com/api/kase/59' }
        )
      end

      subject { CapsuleCRM::Case.create name: 'Test Case', party: party }

      it { should be_a(CapsuleCRM::Case) }

      it { subject.id.should eql(59) }
    end

    context 'when the case is invalid' do
      let(:kase) { CapsuleCRM::Case.create name: 'Test Case' }

      it { kase.errors.should_not be_blank }
    end

    context 'when the case has a track' do
      before do
        stub_request(:post, "#{request_uri}?trackId=#{track.id}").to_return(
          headers: { 'Location' => 'https://sample.capsulecrm.com/api/kase/59' }
        )
      end

      let(:track) { CapsuleCRM::Track.new(id: rand(10)) }

      subject do
        CapsuleCRM::Case.create(name: 'Test Case', party: party, track: track)
      end

      it { expect(subject).to be_a(CapsuleCRM::Case) }

      it { expect(subject).to be_persisted }

      it 'should add the trackId to the URI' do
        subject
        expect(WebMock).
          to have_requested(:post, "#{request_uri}?trackId=#{track.id}")
      end
    end
  end

  describe '.create!' do
    context 'when the case is valid' do
      before do
        stub_request(
          :post, 'https://1234:@company.capsulecrm.com/api/party/1/kase'
        ).to_return(
          headers: { 'Location' => 'https://sample.capsulecrm.com/api/kase/61' }
        )
      end

      let(:party) { CapsuleCRM::Person.new(id: 1, first_name: 'Matt') }

      subject { CapsuleCRM::Case.create! name: 'Test Case', party: party }

      it { should be_a(CapsuleCRM::Case) }

      it { subject.id.should eql(61) }
    end

    context 'when the case is invalid' do
      let(:kase) { CapsuleCRM::Case.create! name: 'Test Case' }

      it 'should raise an error' do
        expect { kase }.to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#update_attributes' do
    context 'when the case is valid' do
      let(:party) { CapsuleCRM::Person.new(id: 10) }

      let(:kase) do
        CapsuleCRM::Case.new(id: 1, name: 'Test Case', party: party)
      end

      before do
        stub_request(
          :put, 'https://1234:@company.capsulecrm.com/api/kase/1'
        ).to_return(status: 200)
        kase.update_attributes name: 'changed name'
      end

      it { kase.name.should eql('changed name') }

      it { kase.id.should eql(1) }
    end

    context 'when the case is not valid' do
      let(:kase) { CapsuleCRM::Case.new(id: 2, name: 'Test Case') }

      before do
        kase.update_attributes name: 'changed name'
      end

      it { kase.errors.should_not be_blank }

      it { kase.name.should eql('changed name') }
    end
  end

  describe '#update_attributes!' do
    context 'when the case is valid' do
      let(:party) { CapsuleCRM::Person.new(id: 1, first_name: 'Matt') }

      let(:kase) do
        CapsuleCRM::Case.new(id: 1, name: 'Test Case', party: party)
      end

      before do
        stub_request(
          :put, 'https://1234:@company.capsulecrm.com/api/kase/1'
        ).to_return(status: 200)
        kase.update_attributes! name: 'changed name'
      end

      it { kase.name.should eql('changed name') }

      it { kase.id.should eql(1) }
    end

    context 'when the case is invalid' do
      let(:kase) { CapsuleCRM::Case.new(id: 1, name: 'Test Case') }

      subject { kase.update_attributes! name: 'changed name' }

      it do
        expect { subject }.to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#save' do
    let(:party) { CapsuleCRM::Person.new(id: 1) }

    context 'when it is a new record' do
      context 'when it is valid' do
        let(:kase) { CapsuleCRM::Case.new(name: 'Test', party: party) }

        before do
          stub_request(
            :post, 'https://1234:@company.capsulecrm.com/api/party/1/kase'
          ).to_return(
            headers: { 'Location' => 'https://sample.capsulecrm.com/api/kase/2' }
          )
          kase.save
        end

        subject { kase }

        it { should be_persisted }

        it { kase.id.should eql(2) }
      end

      context 'when it is invalid' do
        let(:kase) { CapsuleCRM::Case.new(name: 'Test') }

        before { kase.save }

        it { kase.errors.should_not be_blank }

        it { kase.should_not be_persisted }
      end
    end

    context 'when it is an existing record' do
      let(:party) { CapsuleCRM::Person.new(id: 1) }

      context 'when it is valid' do
        let(:kase) { CapsuleCRM::Case.new(id: 2, name: 'Test', party: party) }

        before do
          stub_request(
            :put, 'https://1234:@company.capsulecrm.com/api/kase/2'
          ).to_return(status: 200)
          kase.name = 'changed name'
          kase.save
        end

        it { kase.should be_persisted }

        it { kase.name.should eql('changed name') }
      end

      context 'when it is invalid' do
        let(:kase) { CapsuleCRM::Case.new(id: 2, name: 'Test') }

        before { kase.save }

        it { kase.should be_persisted }

        it { kase.errors.should_not be_blank }
      end
    end
  end

  describe '#save!' do
    let(:party) { CapsuleCRM::Person.new(id: 1) }

    context 'when it is a new record' do
      context 'when it is valid' do
        let(:kase) { CapsuleCRM::Case.new(name: 'Test Case', party: party) }

        before do
          stub_request(:post, /^https.*\/api\/party\/1\/kase$/).
            to_return(headers: {
            'Location' => 'https://sample.capsulecrm.com/api/kase/59'
          })
          kase.save!
        end

        it { kase.should be_persisted }
      end

      context 'when it is invalid' do
        let(:kase) { CapsuleCRM::Case.new(name: 'Test Case') }

        it do
          expect { kase.save! }.
            to raise_error(CapsuleCRM::Errors::RecordInvalid)
        end
      end
    end

    context 'when it is not a new record' do
      context 'when it is valid' do
        let(:kase) do
          CapsuleCRM::Case.new(id: 1, name: 'Test Case', party: party)
        end

        before do
          stub_request(:put, /^.*\/api\/kase\/1$/).to_return(status: 200)
          kase.save!
        end

        it { kase.should be_persisted }
      end

      context 'when it is invalid' do
        let(:kase) do
          CapsuleCRM::Case.new(id: 1, name: 'Test Case')
        end

        it do
          expect { kase.save! }.
            to raise_error(CapsuleCRM::Errors::RecordInvalid)
        end
      end
    end
  end

  describe '#destroy' do
    let(:party) { CapsuleCRM::Person.new(id: 2) }

    let(:kase) { CapsuleCRM::Case.new(id: 1, party: party, name: 'Test Case') }

    before do
      stub_request(:delete, /^.*\/api\/kase\/1$/).to_return(status: 200)
      kase.destroy
    end

    it { kase.should_not be_persisted }
  end

  describe '#new_record?' do
    describe 'when it is a new record' do

      subject { CapsuleCRM::Case.new }

      it { should be_new_record }
    end

    describe 'when it is not a new record' do
      subject { CapsuleCRM::Case.new(id: 1) }

      it { should_not be_new_record }
    end
  end

  describe '#persisted?' do
    context 'when it is persisted' do
      subject { CapsuleCRM::Case.new(id: 1) }

      it { should be_persisted }
    end

    context 'when it is not persisted' do
      subject { CapsuleCRM::Case.new }

      it { should_not be_persisted }
    end
  end
end
