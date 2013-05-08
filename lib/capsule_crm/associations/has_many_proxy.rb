module CapsuleCRM
  module Associations
    class HasManyProxy < BasicObject

      def initialize(parent, target_klass, target, source)
        @target         = target
        @parent         = parent
        @target_klass   = target_klass
        @source         = source
      end

      def method_missing(name, *args, &block)
        @target.send(name, *args, &block)
      end

      def build(attributes = {})
        target_klass.new(attributes).tap do |item|
          item.send("#{source}=", parent)
          @target << item
        end
      end

      def create(attributes = {})
        build(attributes).save
      end

      def tap
        yield self
        self
      end

      private

      def parent
        @parent
      end

      def target_klass
        @target_klass
      end

      def source
        @source
      end
    end
  end
end
