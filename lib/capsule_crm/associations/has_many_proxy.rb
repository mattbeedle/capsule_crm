module CapsuleCRM
  module Associations
    class HasManyProxy < BasicObject

      def initialize(parent, target_klass, target, source, embedded)
        @target         = target
        @parent         = parent
        @target_klass   = target_klass
        @source         = source
        @embedded       = embedded
      end

      def method_missing(name, *args, &block)
        target.send(name, *args, &block)
      end

      def build(attributes = {})
        target_klass.new(attributes).tap do |item|
          item.send("#{source}=", parent)
          target << item
        end
      end

      def create(attributes = {})
        record = build(attributes).tap do |r|
          record_not_saved(r) unless parent.persisted?
        end
        embedded? ? save : record.save
      end

      def tap
        yield self
        self
      end

      def to_capsule_json(root = nil)
        { root => target.map(&:to_capsule_json) }
      end

      private

      def save
        json = to_capsule_json(target_klass.serializable_options.collection_root)
        path = [
          '/api', parent.class.connection_options[:plural], parent.id,
          target_klass.connection_options[:plural]
        ].join('/')
        ::CapsuleCRM::Connection.put(path, json)
      end

      def embedded?
        @embedded
      end

      def record_not_saved(record)
        raise ::CapsuleCRM::Errors::RecordNotSaved.new(record)
      end

      def target
        @target
      end

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
