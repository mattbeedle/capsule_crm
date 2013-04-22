module CapsuleCRM
  module Contactable
    extend ActiveSupport::Concern

    def contacts=(contacts)
      @contacts = contacts
    end

    def contacts
      @contacts
    end
  end
end
