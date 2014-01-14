require 'spec_helper'

describe CapsuleCRM::Milestone do
  before { configure }

  describe 'validations' do
    it { should validate_numericality_of(:id) }
  end

  it_behaves_like 'listable', '/opportunity/milestones', 'milestones', 4
end
