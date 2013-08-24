module CapsuleCRM
  module Attributes
    extend ActiveSupport::Concern

    def attributes=(attributes)
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
      self
    end
  end
end
