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

      def reload
        self.attributes = self.class.find(id).attributes
        associations.keys.each do |association_name|
          instance_variable_set(:"@#{association_name}", nil)
        end
        self
      end
    end
  end
end
