require 'spec_helper'

describe CapsuleCRM::Track do
  before { configure }

  describe 'validations' do
    it { should validate_numericality_of(:id) }
  end

  it_behaves_like 'listable', '/tracks', 'tracks', 2
end
