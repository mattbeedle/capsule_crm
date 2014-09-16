module CapsuleCRM
  module Errors
    class AssociationTypeMismatch < StandardError
      def initialize(args)
        received, expected = *args
        super "#{expected} expected, received #{received}"
      end
    end
  end
end
