module CapsuleCRM
  module Errors
    class ResponseError < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def to_s
        JSON.parse(response.body)['message']
      end
    end
  end
end
