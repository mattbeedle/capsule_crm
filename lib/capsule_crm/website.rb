module CapsuleCRM
  class Website
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Validations

    include CapsuleCRM::Inspector
    include CapsuleCRM::Serializable

    serializable_config do |config|
      config.include_root = false
      config.exclude_id   = false
    end

    attribute :id, Integer
    attribute :type, String
    attribute :web_service, String
    attribute :web_address, String

    validates :web_service, :web_address, presence: true

    def initialize(attributes = {})
      CapsuleCRM::HashHelper.underscore_keys!(attributes)
      super(attributes)
    end
  end
end
