module CapsuleCRM
  module Errors
    class RecordInvalid < StandardError
      attr_reader :record

      def initialize(record)
        @record = record
        super(record.errors.full_messages.join(', '))
      end
    end
  end
end
