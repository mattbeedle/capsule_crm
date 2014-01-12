module CapsuleCRM
  module Serializable
    extend ActiveSupport::Concern

    included do
      class_attribute :serializable_options

      self.serializable_options = OpenStruct.new(
        collection_root: self.to_s.demodulize.downcase.pluralize,
        root: self.to_s.demodulize.downcase.singularize,
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
        CapsuleCRM::Serializer.normalize(self, json)
      end

      def serializable_config
        yield(serializable_options)
      end
    end
  end
end
