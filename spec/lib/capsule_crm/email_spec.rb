require 'spec_helper'

describe CapsuleCRM::Email do
  it_behaves_like 'capsule jsonable' do
    let(:object) { CapsuleCRM::Email.new(email_address: Faker::Internet.email) }
  end
end
