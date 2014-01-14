require 'spec_helper'

describe CapsuleCRM::Currency do
  before { configure }

  it_behaves_like 'listable', '/currencies', 'currencies', 3
end
