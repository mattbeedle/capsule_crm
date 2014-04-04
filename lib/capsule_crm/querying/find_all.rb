module CapsuleCRM
  module Querying
    module FindAll
      extend ActiveSupport::Concern

      module ClassMethods
        def all(options = {})
          CapsuleCRM::Normalizer.new(self).normalize_collection(
            CapsuleCRM::Connection.
            get("/api/#{queryable_options.plural}", options)
          )
        end

        def first
          all(limit: 1).first
        end
      end
    end
  end
end
