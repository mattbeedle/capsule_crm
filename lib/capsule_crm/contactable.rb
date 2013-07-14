module CapsuleCRM
  module Contactable
    extend ActiveSupport::Concern

    included do
      delegate :phones,     to: :contacts, allow_nil: true
      delegate :phones=,    to: :contacts
      delegate :websites,   to: :contacts, allow_nil: true
      delegate :websites=,  to: :contacts
      delegate :emails,     to: :contacts, allow_nil: true
      delegate :emails=,    to: :contacts
      delegate :addresses,  to: :contacts, allow_nil: true
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
