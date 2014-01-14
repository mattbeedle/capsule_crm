require 'spec_helper'

describe CapsuleCRM::User do
  before { configure }

  it_behaves_like 'listable', '/users', 'users', 2
end
