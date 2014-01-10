module CapsuleCRM
  module Serializable
    extend ActiveSupport::Concern

    included do
      class_attribute :serializable_options
      self.serializable_options = {}
    end

    def to_capsule_json
      serializer.serialize
    end

    def serializer
      @serializer ||= CapsuleCRM::Serializer.new(
        self, self.serializable_options
      )
    end
  end
end
