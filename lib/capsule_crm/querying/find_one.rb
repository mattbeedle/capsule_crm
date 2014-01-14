module CapsuleCRM
  module Querying
    module FindOne
      extend ActiveSupport::Concern

      module ClassMethods
        def find(id)
          from_capsule_json CapsuleCRM::Connection.
            get("/api/#{queryable_options.singular}/#{id}")
        end
      end
    end
  end
end
