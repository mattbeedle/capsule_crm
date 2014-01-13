module CapsuleCRM
  module Querying
    module Configuration
      def self.included(base)
        base.send :class_attribute, :queryable_options
        base.extend CapsuleCRM::Querying::Configuration::ClassMethods

        base.queryable_options = OpenStruct.new(
          plural: base.to_s.demodulize.downcase.pluralize,
          singular: base.to_s.demodulize.downcase.singularize
        )
      end

      module ClassMethods
        def queryable_config
          yield(queryable_options)
        end
      end
    end
  end
end
