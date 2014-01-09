module CapsuleCRM
  module Associations
    class BelongsToAssociation
      attr_reader :association_name, :defined_on, :options

      # Public: Initialize a new CapsuleCRM::Associations::BelongsToAssociation
      #
      # association_name  - The Symbol name of the association
      # defined_on        - The String name of the class that this association
      # is defined on
      # options           - The Hash of association options
      #                     foreign_key - The String foreign_key column name
      #                     class_name  - The String name of the parent class
      #
      # Examples
      #
      # CapsuleCRM::Associations::BelongsToAssociation.new(
      #   :person, 'CapsuleCRM::Opportunity', class_name: 'CapsuleCRM::Person'
      # )
      #
      # Returns a CapsuleCRM::Associations::BelongsToAssociation
      def initialize(association_name, defined_on, options)
        @association_name = association_name
        @defined_on       = defined_on
        @options          = options
      end

      # Public: Build the foreign key column name. If a foreign key name was
      # supplied in the options during initialization, then that is returned.
      # Otherwise it is inferred from the association name
      #
      # Returns a String foreign key name
      def foreign_key
        @foreign_key ||= options[:foreign_key] || "#{association_name}_id"
      end

      # Public: Find the parent object of the supplied object
      #
      # object  - The object to find the parent for
      #
      # Examples
      #
      # association = CapsuleCRM::Associations::BelongsToAssociation.new(
      #   :person, 'CapsuleCRM::Opportunity', class_name: 'CapsuleCRM::Person'
      # )
      # object = CapsuleCRM::Opportunity.first
      # association.parent(object)
      #
      # Returns an Object that is on the parent side of the belongs to
      # association
      def parent(object)
        target_klass.find(object.send(foreign_key))
      end

      # Public: The type of association. Just a convenience method
      #
      # Returns a Symbol :belongs_to
      def macro
        :belongs_to
      end

      # Public: The key to use when serializing this association
      #
      # Returns the String key
      def serializable_key
        @serializable_key ||= options[:serializable_key] || foreign_key
      end

      private

      def target_klass
        @target_klass ||= options[:class_name].constantize
      end
    end
  end
end
