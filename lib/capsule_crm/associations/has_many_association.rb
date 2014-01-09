module CapsuleCRM
  module Associations
    class HasManyAssociation
      attr_reader :association_name, :options, :defined_on

      # Public: Initialize a new CapsuleCRM::Associations::HasManyAssociation
      #
      # association_name  - The Symbox association name
      # defined_on        - The String name of the class that this association
      # is defined on
      # options           - The Hash of association options
      #                     :class_name - The String name of the belongs to
      #                     class
      #                     :source - The Symbol name of the accessor method on
      #                     the belongs to class
      #
      # Examples
      #
      # CapsuleCRM::Associations::HasManyAssociation.new(
      #   :opportunities, CapsuleCRM::Person, class_name:
      #   'CapsuleCRM::Opportunity, source: :person
      # )
      #
      # Returns a CapsuleCRM::Associations::HasManyAssociation
      def initialize(association_name, defined_on, options)
        @association_name = association_name
        @options          = options
        @defined_on       = defined_on
      end

      # Public: Build the HasManyProxy object
      #
      # parent      - The instance of the class that the has many assocation is
      # defined on
      # collection  - An optional Array or Hash to use as the target for the
      # proxy
      #
      # Returns a CapsuleCRM::Associations::HasManyProxy
      def proxy(parent, collection = nil)
        CapsuleCRM::Associations::HasManyProxy.new(
          parent, target_klass, build_target(parent, collection), source
        )
      end

      # Public: The type of association. Just a convenience method
      #
      # Return a Symbol :has_many
      def macro
        :has_many
      end

      private

      def build_target(parent, collection)
        collection.nil? ? target(parent) : collection_to_array(collection)
      end

      def collection_to_array(collection)
        if collection.is_a?(Hash)
          Array(target_klass.new(collection[collection.keys.first]))
        else
          collection
        end
      end

      def target_klass
        @target_klass ||= options[:class_name].constantize
      end

      def target(parent)
        target_klass.
          send("_for_#{parent.class.to_s.demodulize.downcase}", parent.id)
      end

      def source
        @source ||= options[:source]
      end
    end
  end
end
