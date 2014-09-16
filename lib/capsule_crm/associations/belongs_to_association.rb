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

      def inverse
        @inverse ||=
          target_klass.has_many_associations.find do |name, association|
          association.source == association_name &&
            association.target_klass == defined_on
        end.try(:last) if target_klass.respond_to?(:has_many_associations)
      end

      # Public: Build the foreign key column name. If a foreign key name was
      # supplied in the options during initialization, then that is returned.
      # Otherwise it is inferred from the association name
      #
      # Returns a String foreign key name
      def foreign_key
        @foreign_key ||= options[:foreign_key] || infer_foreign_key
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

      def serialize
        @serialize ||= options[:serialize] == false ? false : true
      end

      def check_object!(object)
        association_mismatch!(object) if object_invalid?(object)
      end

      private

      def enforce_type?
        true unless options[:enforce_type] == false
      end

      def object_invalid?(object)
        enforce_type? && !object.is_a?(target_klass)
      end

      def association_mismatch!(object)
        fail CapsuleCRM::Errors::AssociationTypeMismatch,
          [object.class, target_klass], caller
      end

      def infer_foreign_key
        "#{association_name}_id"
      end

      def target_klass
        @target_klass ||=
          (options[:class_name] || infer_target_klass).constantize
      end

      def infer_target_klass
        "CapsuleCRM::#{association_name.to_s.camelize}"
      end
    end
  end
end
