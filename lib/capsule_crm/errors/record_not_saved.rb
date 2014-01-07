module CapsuleCRM
  module Errors
    class RecordNotSaved < StandardError
      attr_reader :record

      def initialize(record)
        @record = record
      end

      def message
        [
          'CapsuleCRM::Errors::RecordNotSaved',
          'You cannot call create unless the parent is saved'
        ].join(': ')
      end
    end
  end
end
