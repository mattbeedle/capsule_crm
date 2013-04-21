module CapsuleCRM
  module Associations
    module HasMany
      extend ActiveSupport::Concern

      module ClassMethods
        def has_many(type, options = {})
        end
      end
    end
  end
end
