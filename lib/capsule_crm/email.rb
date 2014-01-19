module CapsuleCRM
  class Email
    include Virtus.model
    include CapsuleCRM::Serializable
    extend  ActiveModel::Naming

    serializable_config do |config|
      config.include_root = false
    end

    attribute :type
    attribute :email_address

    def initialize(attributes = {})
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end
  end
end
