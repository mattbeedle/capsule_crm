module CapsuleCRM
  module Associations
    class HasManyProxy < BasicObject

      def initialize(target = nil)
        @target = target
      end

      def method_missing(name, *args, &block)
        target.send(name, *args, &block)
      end

      def build(attributes = {})
      end

      def create(attributes = {})
      end

      private

      def target
        @target ||= []
      end
    end
  end
end
