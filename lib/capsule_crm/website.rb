module CapsuleCRM
  class Website
    include Virtus

    extend  ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Serializers::JSON

    attribute :type
    attribute :web_service
    attribute :web_address

    validates :web_service, :web_address, presence: true
  end
end
