shared_examples 'contactable' do
  it { expect(described_class.new).to respond_to(:contacts) }

  it { expect(described_class.new).to respond_to(:contacts=) }

  it { expect(described_class.new).to respond_to(:phones) }

  it { expect(described_class.new).to respond_to(:phones=) }

  it { expect(described_class.new).to respond_to(:websites) }

  it { expect(described_class.new).to respond_to(:websites=) }

  it { expect(described_class.new).to respond_to(:emails) }

  it { expect(described_class.new).to respond_to(:emails=) }

  it { expect(described_class.new).to respond_to(:addresses) }

  it { expect(described_class.new).to respond_to(:addresses=) }
end
