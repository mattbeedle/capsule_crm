require 'spec_helper'

describe CapsuleCRM::Country do
  before { configure }

  it_behaves_like 'listable', '/countries', 'countries', 2
end
