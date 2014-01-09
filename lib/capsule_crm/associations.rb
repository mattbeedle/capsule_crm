require 'capsule_crm/associations/belongs_to'
require 'capsule_crm/associations/has_many'

module CapsuleCRM
  module Associations
    extend ActiveSupport::Concern

    included do
      include CapsuleCRM::Associations::BelongsTo
      include CapsuleCRM::Associations::HasMany

      class_attribute :associations
      self.associations = {}
    end

    module ClassMethods
      # Public: Gets all the has many associations defined on the class
      #
      # Returns a Hash
      def has_many_associations
        select_associations(:has_many)
      end

      # Public: Get all the belongs to associations defined on the class
      #
      # Returns a Hash
      def belongs_to_associations
        select_associations(:belongs_to)
      end

      def select_associations(macro)
        associations.select do |name, association|
          association.macro == macro &&
            [self, self.parent].include?(association.defined_on)
        end
      end
    end
  end
end
