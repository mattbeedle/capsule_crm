module CapsuleCRM
  module Associations
    module BelongsTo
      extend ActiveSupport::Concern

      module ClassMethods
        def belongs_to(type, options = {})
        end
      end
    end
  end
end
