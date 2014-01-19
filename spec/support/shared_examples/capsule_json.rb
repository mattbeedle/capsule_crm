shared_examples 'capsule jsonable' do
  subject { object.to_capsule_json }
  let(:attributes) do
    object.attributes.delete_if { |key, value| value.blank? }
  end

  if described_class.serializable_options.exclude_id == false
    context 'when exclude_id is false' do
      context "when the #{described_class} has an ID" do
        before { object.id = Random.rand(1..100) }

        it 'should include the ID' do
          expect(subject.keys).to include('id')
        end
      end

      context "when the #{described_class} has no ID" do
        it 'should return a capsule compatible hash' do
          expect(subject).
            to eql(CapsuleCRM::HashHelper.camelize_keys(attributes))
        end
      end
    end
  end
end
