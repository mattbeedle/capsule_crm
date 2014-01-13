require 'spec_helper'

describe CapsuleCRM::Track do
  before { configure }

  describe 'validations' do
    it { should validate_numericality_of(:id) }
  end

  it_behaves_like 'listable', File.read('spec/support/tracks.json'), 2
end
