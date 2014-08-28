require 'spec_helper'

describe CapsuleCRM::Errors::ResponseError do
  let(:error) { CapsuleCRM::Errors::ResponseError.new(response) }

  subject { error.to_s }

  describe '#to_s' do
    context 'when the response is not nil' do
      let(:response) { double('Response', body: response_body.to_json) }
      let(:response_body) do
        { message: 'this is an error message from the server' }
      end
      let(:error) { CapsuleCRM::Errors::ResponseError.new(response) }

      it 'should include the server error message' do
        expect(subject).to eql(response_body[:message])
      end
    end

    context 'when the response is nil' do
      let(:response) { nil }

      it 'should return an empty response message' do
        expect(subject).to eql('capsulecrm.com returned an empty response')
      end
    end
  end
end