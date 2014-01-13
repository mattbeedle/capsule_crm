require 'spec_helper'

describe CapsuleCRM::User do
  before { configure }

  it_behaves_like 'listable', File.read('spec/support/all_users.json'), 2
end
