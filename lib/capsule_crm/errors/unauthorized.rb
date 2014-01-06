module CapsuleCRM
  module Errors
    class Unauthorized < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
      end
    end
  end
end
