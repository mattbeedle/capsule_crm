require 'spec_helper'

describe CapsuleCRM::Faraday::Middleware::RaiseError do
  describe '#on_complete' do
    subject { described_class.new }

    context 'when the response is a success' do
      let(:response) { Hash[status: 200] }

      it 'should return nothing' do
        expect(subject.on_complete(response)).to eql(nil)
      end
    end

    context 'when the response is a 400' do
      let(:response) do
        OpenStruct.new(status: 400, body: { message: 'test' }.to_json)
      end

      it 'should raise a bad request error' do
        expect { subject.on_complete(response) }.
          to raise_error(CapsuleCRM::Errors::BadRequest)
      end
    end

    context 'when the response is a 401' do
      let(:response) do
        OpenStruct.new(status: 401, body: { message: 'test' }.to_json)
      end

      it 'should raise a not authorized error' do
        expect { subject.on_complete(response) }.
          to raise_error(CapsuleCRM::Errors::NotAuthorized)
      end
    end

    context 'when the response is a 404' do
      let(:response) do
        OpenStruct.new(status: 404, body: { message: 'test' }.to_json)
      end

      it 'should raise a not found error' do
        expect { subject.on_complete(response) }.
          to raise_error(CapsuleCRM::Errors::NotFound)
      end
    end

    context 'when the response is a 500' do
      let(:response) do
        OpenStruct.new(status: 500, body: { message: 'test' }.to_json)
      end

      it 'should raise an internal server error' do
        expect { subject.on_complete(response) }.
          to raise_error(CapsuleCRM::Errors::InternalServerError)
      end
    end
  end
end
