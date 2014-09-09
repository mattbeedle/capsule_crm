module CapsuleCRM
  class Attachment
    include Virtus.model

    include ActiveModel::Validations
    include CapsuleCRM::Inspector

    attribute :id,            Integer
    attribute :filename,      String
    attribute :content_type,  String

    validates :id, numericality: { allow_blank: true }
  end
end
