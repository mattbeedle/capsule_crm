require 'spec_helper'

describe CapsuleCRM::Currency do
  before { configure }

  it_behaves_like 'listable', File.read('spec/support/currencies.json'), 3
end
