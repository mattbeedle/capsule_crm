module CapsuleCRM
  module Associations
    class BelongsToFinder
      attr_reader :association
      attr_writer :singular, :plural, :normalizer

      def initialize(association)
        @association = association
      end

      def call(id)
        id ? find(id) : []
      end

      private

      def inverse
        @inverse ||= association.inverse
      end

      def singular
        @singular ||= inverse.defined_on.queryable_options.singular
      end

      def plural
        @plural ||= association.defined_on.queryable_options.plural
      end

      def find(id)
        normalizer.normalize_collection get(path(id)) if inverse
      end

      def get(path_string)
        CapsuleCRM::Connection.get(path_string)
      end

      def path(id)
        "/api/#{singular}/#{id}/#{plural}"
      end

      def normalizer
        @normalizer ||= CapsuleCRM::Normalizer.new(association.defined_on)
      end
    end
  end
end
