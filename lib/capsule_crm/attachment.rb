module CapsuleCRM
  class Attachment
    include Virtus.model

    attribute :id,            Integer
    attribute :filename,      String
    attribute :content_type,  String
  end
end
