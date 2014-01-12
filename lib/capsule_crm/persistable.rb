module CapsuleCRM
  module Persistable
    extend ActiveSupport::Concern

    def self.included(base)
      base.send :class_attribute, :connection_options

      base.connection_options = OpenStruct.new(
        plural: base.to_s.demodulize.downcase.pluralize,
        singular: base.to_s.demodulize.downcase.singularize
      )
    end

    module ClassMethods
      def persistable_config
        yield(connection_options)
      end
    end
  end
end
