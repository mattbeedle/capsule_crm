require 'spec_helper'

describe CapsuleCRM::TaskCategory do
  before { configure }

  it_behaves_like 'listable', '/task/categories', 'categories', 6
end
