require 'spec_helper'

describe CapsuleCRM::Errors do
  describe '.error_from_env' do
    let(:env) { OpenStruct.new(body: { message: 'test' }.to_json) }

    subject { described_class.error_from_env(env) }

    context 'with a 400 response' do
      before { env.status = 400 }

      it 'should return a bad request error' do
        expect(subject).to be_a(CapsuleCRM::Errors::BadRequest)
      end
    end

    context 'with a 401 response' do
      before { env.status = 401 }

      it 'should return a not authorized error' do
        expect(subject).to be_a(CapsuleCRM::Errors::NotAuthorized)
      end
    end

    context 'with a 404 response' do
      before { env.status = 404 }

      it 'should return a not found error' do
        expect(subject).to be_a(CapsuleCRM::Errors::NotFound)
      end
    end

    context 'with a 500 response' do
      before { env.status = 500 }

      it 'should return a internal server error' do
        expect(subject).to be_a(CapsuleCRM::Errors::InternalServerError)
      end
    end
  end
end
