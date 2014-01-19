require 'spec_helper'

describe CapsuleCRM::Address do
  it_behaves_like 'capsule jsonable' do
    let(:object) do
      CapsuleCRM::Address.new(street: Faker::Address.street_address)
    end
  end
end
