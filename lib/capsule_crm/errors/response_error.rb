module CapsuleCRM
  module Errors
    class ResponseError < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def to_s
        response_message || empty_message
      end

      private

      def response_message
        JSON.parse(response.body)['message'] if response
      end

      def empty_message
        'capsulecrm.com returned an empty response'
      end
    end
  end
end
