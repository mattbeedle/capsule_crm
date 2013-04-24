module CapsuleCRM
  module Contactable
    extend ActiveSupport::Concern

    included do
      delegate :phones=,    to: :contacts
      delegate :websites=,  to: :contacts
      delegate :emails=,    to: :contacts
      delegate :addresses=, to: :contacts
    end

    def contacts=(contacts)
      @contacts = contacts
    end

    def contacts
      @contacts ||= CapsuleCRM::Contacts.new
    end
  end
end
