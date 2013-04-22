module CapsuleCRM
  class Contacts

    def addresses=(addresses)
      @addresses = addresses
    end

    def addresses
      @addresses || []
    end
  end
end
