module CapsuleCRM
  module Contactable
    extend ActiveSupport::Concern

    def contacts=(contacts)
      @contacts = contacts
    end

    def contacts
      @contacts ||= CapsuleCRM::Contacts.new
    end
  end
end
