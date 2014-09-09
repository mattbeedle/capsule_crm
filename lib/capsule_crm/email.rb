module CapsuleCRM
  class Email
    include Virtus.model

    include CapsuleCRM::Inspector
    include CapsuleCRM::Serializable

    extend  ActiveModel::Naming

    serializable_config do |config|
      config.include_root = false
      config.exclude_id   = false
    end

    attribute :id, Integer
    attribute :type
    attribute :email_address

    def initialize(attributes = {})
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end
  end
end
