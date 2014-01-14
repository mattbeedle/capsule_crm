require_relative 'belongs_to_association'

module CapsuleCRM
  module Associations
    module BelongsTo
      extend ActiveSupport::Concern

      module ClassMethods

        # Public: Add getter and setter methods for belongs to associations
        #
        # association_name  - The String name of the association
        # options           - The Hash of additional options (default: {}):
        #                     class_name: The String name of the associated
        #                     class
        #
        # Examples
        #
        # class CapsuleCRM::Person
        #   include CapsuleCRM::Associations::BelongsTo
        #
        #   belongs_to :organisation, class_name: 'CapsuleCRM::Organization'
        # end
        #
        # organisation = CapsuleCRM::Organisation.find(1)
        #
        # person = CapsuleCRM::Person.new(organisation = organisation)
        # person.organisation_id
        # => 1
        #
        # person.organisation
        # => organisation
        def belongs_to(association_name, options = {})
          association = CapsuleCRM::Associations::BelongsToAssociation.
            new(association_name, self, options)
          self.associations[association_name] = association

          class_eval do
            attribute association.foreign_key, Integer
          end

          (class << self; self; end).instance_eval do
            define_method "_for_#{association_name}" do |id|
              if association.inverse# && !association.inverse.embedded
                CapsuleCRM::Normalizer.new(self).normalize_collection(
                  CapsuleCRM::Connection.get("/api/#{association.inverse.defined_on.queryable_options.singular}/#{id}/#{self.queryable_options.plural}")
                )
              end
            end
          end

          define_method association_name do
            instance_variable_get(:"@#{association_name}") ||
              if self.send(association.foreign_key)
                association.parent(self).tap do |object|
                  self.send("#{association_name}=", object)
                end
              end
          end

          define_method "#{association_name}=" do |associated_object|
            associated_object.tap do |object|
              instance_variable_set(:"@#{association_name}", associated_object)
              self.send "#{association.foreign_key}=", associated_object.try(:id)
            end
          end
        end
      end
    end
  end
end
