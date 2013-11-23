module CapsuleCRM
  class Tag
    include Virtus.model

    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :name

    validates :name, presence: true
  end
end