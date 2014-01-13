require 'spec_helper'

describe CapsuleCRM::Country do
  before { configure }

  it_behaves_like 'listable', File.read('spec/support/countries.json'), 2
end
