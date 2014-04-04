module CapsuleCRM
  module Associations
    class BelongsToFinder
      attr_reader :association
      attr_writer :singular, :plural, :normalizer

      def initialize(association)
        @association = association
      end

      def call(id)
        id ? find_by_parent_id(id) : []
      end

      private

      def inverse
        @inverse ||= association.inverse
      end

      def embedded?
        inverse.embedded
      end

      def singular
        @singular ||= inverse.defined_on.queryable_options.singular
      end

      def plural
        @plural ||= association.defined_on.queryable_options.plural
      end

      def find_by_parent_id(id)
        normalizer.normalize_collection(get(path(id))).tap do |collection|
          collection.each do |item|
            item.send("#{association.foreign_key}=", id)
          end if embedded?
        end
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
