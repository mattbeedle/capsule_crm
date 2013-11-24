module CapsuleCRM
  class Attachment
    include Virtus

    attribute :id,            Integer
    attribute :filename,      String
    attribute :content_type,  String
  end
end
