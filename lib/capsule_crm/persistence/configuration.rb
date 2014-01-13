module CapsuleCRM
  module Persistence
    module Configuration
      extend ActiveSupport::Concern

      def self.included(base)
        base.send :class_attribute, :connection_options

        klass_name = base.to_s.demodulize.downcase

        base.connection_options = OpenStruct.new(
          create: lambda { |object| "#{klass_name.pluralize}" },
          update: lambda { |object| "#{klass_name.singularize}/#{object.id}" },
          destroy: lambda { |object| "#{klass_name.singularize}/#{object.id}" }
        )
      end

      module ClassMethods
        def persistable_config
          yield(connection_options)
        end
      end
    end
  end
end
