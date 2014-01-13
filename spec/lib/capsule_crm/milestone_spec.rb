require 'spec_helper'

describe CapsuleCRM::Milestone do
  before { configure }

  describe 'validations' do
    it { should validate_numericality_of(:id) }
  end

  it_behaves_like 'listable', File.read('spec/support/milestones.json'), 4
end
