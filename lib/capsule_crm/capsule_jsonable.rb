module CapsuleCRM
  module CapsuleJsonable
    extend ActiveSupport::Concern

    def to_capsule_json
      serializer.serialize.delete(serializer.root)
    end

    def serializer
      @serializer ||= CapsuleCRM::Serializer.new(self)
    end
  end
end
