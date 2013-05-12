require 'spec_helper'

describe CapsuleCRM::Tag do

  it { should validate_presence_of(:name) }
end
