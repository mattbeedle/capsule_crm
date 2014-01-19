require 'spec_helper'

describe CapsuleCRM::Website do
  it_behaves_like 'capsule jsonable' do
    let(:object) do
      CapsuleCRM::Website.new(web_address: Faker::Internet.domain_name)
    end
  end
end
