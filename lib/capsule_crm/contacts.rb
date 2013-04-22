module CapsuleCRM
  class Contacts

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

    # Public: Builds a hash of all contact information
    #
    # Examples
    #
    # contacts.to_capsule_json
    #
    # Returns a Hash
    def to_capsule_json
      { addresses: addresses.to_json }
    end
  end
end
