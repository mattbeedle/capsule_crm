module CapsuleCRM
  module Associations
    class HasManyProxy < BasicObject

      def method_missing(name, *args, &block)
        target.send(name, *args, &block)
      end

      private

      def target
        @target ||= []
      end
    end
  end
end
