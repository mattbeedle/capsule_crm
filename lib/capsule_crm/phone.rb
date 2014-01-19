module CapsuleCRM
  class Phone
    include Virtus.model
    include CapsuleCRM::Serializable
    extend  ActiveModel::Naming

    serializable_config do |config|
      config.include_root = false
      config.exclude_id   = false
    end

    attribute :id, Integer
    attribute :type, String
    attribute :phone_number, String

    def initialize(attributes = {})
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end
  end
end
