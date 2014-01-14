module CapsuleCRM
  module Serializable
    extend ActiveSupport::Concern

    # We need to use "self.included" here instead of "included do" to make sure
    # that organizations and people don't inherit a pointer to the
    # serializable_options of their parent class and modify that.
    def self.included(base)
      base.send :class_attribute, :serializable_options

      base.serializable_options = OpenStruct.new(
        collection_root: base.to_s.demodulize.downcase.pluralize,
        root: base.to_s.demodulize.downcase.singularize,
        include_root: true,
        excluded_keys: [],
        additional_methods: []
      )
    end

    def to_capsule_json
      serializer.serialize(self)
    end

    def serializer
      @serializer ||= CapsuleCRM::Serializer.new(self.serializable_options)
    end

    module ClassMethods
      def from_capsule_json(json)
        CapsuleCRM::Normalizer.new(self).normalize(json)
      end

      def serializable_config
        yield(serializable_options)
      end
    end
  end
end
