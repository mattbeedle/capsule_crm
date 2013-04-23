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
      self.phones     = attributes[:phones]
      self.websites   = attributes[:websites]
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
    # contacts.emails = [email]
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

    # Public: Sets the phones for this contacts controller
    #
    # phones  - The Array of CapsuleCRM::Phone objects
    #
    # Examples
    #
    # phone = CapsuleCRM::Phone.new(type: 'Mobile', phone_number: '1234')
    # contacts = CapsuleCRM::Contacts.new
    # contacts.phones = [phone]
    #
    # Returns an Array of CapsuleCRM::Phone objects
    def phones=(phones)
      @phones = phones
    end

    # Public: Gets the phones for this contacts container
    #
    # Examples
    #
    # contacts.phones
    #
    # Returns a Hash
    def phones
      @phones || []
    end

    # Public: Sets the websites for this contacts container
    #
    # websites  - The Array of CapsuleCRM::Website objects
    #
    # Examples
    #
    # website = CapsuleCRM::Website.new(
    #   type: 'Work', web_service: 'URL', web_address: 'http://github.com'
    # )
    # contacts = CapsuleCRM::Contacts.new
    # contacts.websites = [website]
    #
    # Returns an Array of CapsuleCRM::Website objects
    def websites=(websites)
      @websites = websites
    end

    # Public: Gets the websites for this contacts container
    #
    # Examples
    #
    # contacts.websites
    #
    # Returns a Hash
    def websites
      @websites || []
    end

    # Public: Builds a hash of all contact information
    #
    # Examples
    #
    # contacts.to_capsule_json
    #
    # Returns a Hash
    def to_capsule_json
      {
        address: address_json, email: email_json
      }.stringify_keys
    end

    private

    def address_json
      addresses.map do |address|
        HashHelper.camelize_keys address.as_json(root: false)
      end
    end

    def email_json
      emails.map do |email|
        HashHelper.camelize_keys email.as_json(root: false)
      end
    end
  end
end
