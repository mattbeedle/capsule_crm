shared_examples 'persistable' do |location, id|
  before do
    stub_request(:get, /[0-9]*\/customfields/).
      to_return(body: File.read('spec/support/no_customfields.json'))
  end

  it 'should add an after_save class method' do
    expect(described_class).to respond_to(:after_save)
  end

  describe '.create' do
    subject { described_class.create attributes }
    before do
      stub_request(:post, /.*/).to_return(headers: { 'Location' => location })
    end

    it "should return an instance of the #{described_class}" do
      expect(subject).to be_a(described_class)
    end

    it 'should be persisted' do
      expect(subject).to be_persisted
    end

    it 'should populate the ID from the response' do
      expect(subject.id).to eql(id)
    end

    described_class.embedded_associations.each do |name, association|
      context "when the #{described_class} has embedded #{name}" do
        let(:collection_root) do
          association.target_klass.serializable_options.collection_root
        end
        let(:plural) { association.target_klass.queryable_options.plural }
        let(:singular) { described_class.queryable_options.singular }
        before do
          stub_request(:get, /[0-9]*\/#{plural}/).
            to_return(body: File.read("spec/support/all_#{plural}.json"))
          stub_request(:put, /[0-9]*\/#{plural}/).
            to_return(body: File.read("spec/support/all_#{plural}.json"))
        end
        subject { described_class.create attributes }

        it "should save the embedded #{name}" do
          expect(WebMock).to have_requested(
            :put, "https://1234:@company.capsulecrm.com/api/#{singular}/#{subject.id}/#{plural}"
          )
        end
      end
    end

    if described_class.attribute_set.map(&:name).include?(:track_id)
      context "when the #{described_class} has a track" do
        let(:track) { CapsuleCRM::Track.new(id: Random.rand(1..10)) }
        subject do
          described_class.create attributes.merge(track: track)
        end

        it "should return an instance of #{described_class}" do
          expect(subject).to be_a(described_class)
        end

        it 'should append the track ID on to the request path' do
          expect(WebMock).to have_requested(
            :post,
            "https://1234:@company.capsulecrm.com#{subject.build_create_path}"
          )
        end
      end
    end

    context "when the #{described_class} is not valid" do
      subject { described_class.create }

      it 'should have errors' do
        expect(subject.errors).not_to be_blank
      end
    end
  end

  describe '.create!' do
    context "when the #{described_class} is valid" do
      subject { described_class.create! attributes }
      before do
        stub_request(:post, /.*/).to_return(headers: { 'Location' => location })
      end

      it "should be a #{described_class}" do
        expect(subject).to be_a(described_class)
      end

      it 'should be persisted' do
        expect(subject).to be_persisted
      end

      it 'should populate the ID from the response' do
        expect(subject.id).to eql(id)
      end
    end

    context "when the #{described_class} is not valid" do
      subject { described_class.create! }

      it 'should raise an error' do
        expect { subject }.to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#update_attributes' do
    context "when the #{described_class} is valid" do
      let(:id) { Random.rand(1..10) }
      subject do
        Fabricate.build(described_class.to_s.demodulize.downcase.to_sym, id: id)
      end
      before do
        stub_request(:put, /.*/).to_return(status: 200)
        subject.update_attributes
      end

      it 'should keep the ID' do
        expect(subject.id).to eql(id)
      end

      it 'should send a PUT request' do
        expect(WebMock).to have_requested(
          :put,
          "https://1234:@company.capsulecrm.com#{subject.build_update_path}"
        )
      end
    end

    context "when the #{described_class} is not valid" do
      subject { described_class.new(id: Random.rand(1..10)) }
      before { subject.update_attributes }

      it 'should have errors' do
        expect(subject.errors).not_to be_blank
      end

      it 'should not send a PUT request' do
        expect(WebMock).not_to have_requested(
          :put,
          "https://1234:@company.capsulecrm.com#{subject.build_update_path}"
        )
      end
    end
  end

  describe '#update_attributes!' do
    context "when the #{described_class} is valid" do
      subject do
        Fabricate.build described_class.to_s.demodulize.downcase.to_sym, id: id
      end
      before do
        stub_request(:put, /.*/).to_return(status: 200)
        subject.update_attributes!
      end

      it 'should send a PUT request' do
        expect(WebMock).to have_requested(
          :put,
          "https://1234:@company.capsulecrm.com#{subject.build_update_path}"
        )
      end
    end

    context "when the #{described_class} is not valid" do
      subject { described_class.new(id: Random.rand(1..10)).update_attributes! }

      it 'should raise an error' do
        expect { subject }.to raise_error(CapsuleCRM::Errors::RecordInvalid)
      end
    end
  end

  describe '#save' do
    context "when the #{described_class} is a new record" do
      context "when the #{described_class} is valid" do
        before do
          stub_request(:post, /.*/).to_return(headers: {
            'Location' => location
          }, status: 200)
        end
        subject do
          Fabricate.build described_class.to_s.demodulize.downcase.to_sym
        end
        before { subject.save }

        it 'should send a POST request' do
          expect(WebMock).to have_requested(
            :post,
            "https://1234:@company.capsulecrm.com#{subject.build_create_path}"
          ).with(body: subject.to_capsule_json)
        end
      end

      context "when the #{described_class} is not valid" do
        subject { described_class.new }
        before { subject.save }

        it 'should not send a POST request' do
          expect(WebMock).not_to have_requested(
            :post,
            "https://1234:@company.capsulecrm.com#{subject.build_create_path}"
          )
        end

        it 'should have errors' do
          expect(subject.errors).not_to be_blank
        end
      end
    end

    context "when the #{described_class} is not a new record" do
      context "when the #{described_class} is valid" do
        subject do
          Fabricate.build described_class.to_s.demodulize.downcase.to_sym,
            id: Random.rand(1..10)
        end
        before do
          stub_request(:put, /.*/).to_return(status: 200)
          subject.save
        end

        it 'should send a PUT request' do
          expect(WebMock).to have_requested(
            :put,
            "https://1234:@company.capsulecrm.com#{subject.build_update_path}"
          ).with(subject.to_capsule_json)
        end
      end

      context "when the #{described_class} is not valid" do
        subject { described_class.new id: Random.rand(1..10) }
        before { subject.save }

        it 'should not send a PUT request' do
          expect(WebMock).not_to have_requested(
            :put,
            "https://1234:@company.capsulecrm.com#{subject.build_update_path}"
          )
        end

        it 'should have errors' do
          expect(subject.errors).not_to be_blank
        end
      end
    end
  end

  describe '#save!' do
    context "when the #{described_class} is a new record" do
      context "when the #{described_class} is not valid" do
        before do
          stub_request(:post, /.*/).to_return(headers: {
            'Location' => location
          }, status: 200)
        end
        subject do
          Fabricate.build described_class.to_s.demodulize.downcase.to_sym
        end
        before { subject.save }

        it 'should send a POST request' do
          expect(WebMock).to have_requested(
            :post,
            "https://1234:@company.capsulecrm.com#{subject.build_create_path}"
          ).with(body: subject.to_capsule_json)
        end

        it 'should populate the ID from the response' do
          expect(subject.id).to eql(id)
        end
      end

      context "when the #{described_class} is not valid" do
        subject { described_class.new.save! }

        it 'should raise an error' do
          expect { subject }.to raise_error(CapsuleCRM::Errors::RecordInvalid)
        end
      end
    end

    context "when the #{described_class} is not a new record" do
      context "when the #{described_class} is valid" do
        subject do
          Fabricate.build described_class.to_s.demodulize.downcase.to_sym,
            id: Random.rand(1..10)
        end
        before do
          stub_request(:put, /.*/).to_return(status: 200)
          subject.save!
        end

        it 'should send a PUT request' do
          expect(WebMock).to have_requested(
            :put,
            "https://1234:@company.capsulecrm.com#{subject.build_update_path}"
          ).with(body: subject.to_capsule_json)
        end
      end

      context "when the #{described_class} is not valid" do
        subject { described_class.new(id: Random.rand(1..10)).save! }

        it 'should raise an error' do
          expect { subject }.to raise_error(CapsuleCRM::Errors::RecordInvalid)
        end
      end
    end
  end

  describe '#new_record?' do
    context "when the #{described_class} is a new record" do
      subject { described_class.new.new_record? }

      it 'should be a new record' do
        expect(subject).to eql(true)
      end
    end

    context "when the #{described_class} is not a new record" do
      subject { described_class.new(id: Random.rand(1..10)).new_record? }

      it 'should not be a new record' do
        expect(subject).to eql(false)
      end
    end
  end

  describe '#persisted?' do
    context "when the #{described_class} is persisted" do
      subject { described_class.new.persisted? }

      it 'should be true' do
        expect(subject).to eql(false)
      end
    end

    context "when the #{described_class} is not persisted" do
      subject { described_class.new(id: Random.rand(1..10)).persisted? }

      it 'should not be persisted' do
        expect(subject).to eql(true)
      end
    end
  end
end
