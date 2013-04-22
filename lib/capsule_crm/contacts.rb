module CapsuleCRM
  class Contacts

    # Public: Initializes a new CapsuleCRM::Contacts object
    #
    # attributes  - The Hash of attributes
    #               :addresses  - The Array of CapsuleCRM::Address objects
    #               :emails     - The Array of CapsuleCRM::Email objects
    #
    # Examples
    #
    # CapsuleCRM::Contacts.new
    #
    # CapsuleCRM::Contacts.new(addresses: addresses, emails: emails)
    #
    # Returns a CapsuleCRM::Contact
    def initialize(attributes = {})
      self.addresses  = attributes[:addresses]
      self.emails     = attributes[:emails]
    end

    # Public: Sets the addresses for this contacts container
    #
    # addresses - The Array of CapsuleCRM::Address objects
    #
    # Examples
    #
    # address = CapsuleCRM::Address.new(street: 'Oranienburgerstrasse')
    # contacts = CapsuleCRM::Contacts.new
    # contacts.addresses = [address]
    # contacts.addresses << address
    #
    # Returns an Array of CapsuleCRM::Address objects
    def addresses=(addresses)
      @addresses = addresses
    end

    # Public: Gets the addresses for this contacts container
    #
    # Examples
    #
    # contacts.addresses
    #
    # Returns an Array of CapsuleCRM::Address objects
    def addresses
      @addresses || []
    end

    # Public: Sets the emails for this contacts container
    #
    # emails  - The Array of CapsuleCRM::Email objects
    #
    # Examples
    #
    # email = CapsuleCRM::Email.new(type: 'HOME', email_address:
    # 'matt@gmail.com')
    # contacts = CapsuleCRM::Contacts.new
    # contacts.emails = [emails]
    #
    # Returns an Array of CapsuleCRM::Email objects
    def emails=(emails)
      @emails = emails
    end

    # Public: Gets the emails for this contacts container
    #
    # Examples
    #
    # contacts.emails
    #
    # Returns an Array of CapsuleCRM::Email objects
    def emails
      @emails || []
    end

    # Public: Builds a hash of all contact information
    #
    # Examples
    #
    # contacts.to_capsule_json
    #
    # Returns a Hash
    def to_capsule_json
      { address: addresses.map(&:to_capsule_json) }.stringify_keys
    end
  end
end
