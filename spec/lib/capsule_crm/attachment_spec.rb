require 'spec_helper'

describe CapsuleCRM::Attachment do
  describe 'validations' do
    it { should validate_numericality_of(:id) }
  end
end