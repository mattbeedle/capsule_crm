require 'capsule_crm/associations/belongs_to'

module CapsuleCRM
  module Associations
    extend ActiveSupport::Concern

    included do
      include CapsuleCRM::Associations::BelongsTo
      include CapsuleCRM::Associations::HasMany
    end
  end
end
