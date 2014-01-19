require 'spec_helper'

describe CapsuleCRM::Phone do
  it_behaves_like 'capsule jsonable' do
    let(:object) { CapsuleCRM::Phone.new(phone_number: '1234') }
  end
end
