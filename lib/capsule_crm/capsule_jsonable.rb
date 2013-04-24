module CapsuleCRM
  module CapsuleJsonable
    extend ActiveSupport::Concern

    def to_capsule_json
      CapsuleCRM::HashHelper.camelize_keys attributes
    end
  end
end
