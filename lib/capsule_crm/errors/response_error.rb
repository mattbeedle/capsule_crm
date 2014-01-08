module CapsuleCRM
  module Errors
    class ResponseError < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
      end
    end
  end
end
