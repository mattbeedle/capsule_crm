module CapsuleCRM
  module Querying
    module FindAll
      extend ActiveSupport::Concern

      module ClassMethods
        def all(options = {})
          CapsuleCRM::Normalizer.new(self).normalize_collection(
            CapsuleCRM::Connection.
            get("/api/#{connection_options.plural}", options)
          )
        end
      end
    end
  end
end
