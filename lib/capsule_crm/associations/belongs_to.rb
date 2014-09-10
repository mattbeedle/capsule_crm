require_relative 'belongs_to_association'
require_relative 'belongs_to_finder'

module CapsuleCRM
  module Associations # nodoc
    module BelongsTo # nodoc
      extend ActiveSupport::Concern

      # nodoc
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
          association = CapsuleCRM::Associations::BelongsToAssociation
            .new(association_name, self, options)
          associations[association_name] = association

          class_eval do
            attribute association.foreign_key, Integer
          end

          (class << self; self; end).instance_eval do
            define_method "_for_#{association_name}" do |id|
              CapsuleCRM::Associations::BelongsToFinder.new(association)
                .call(id)
            end
          end

          define_method association_name do
            instance_variable_get(:"@#{association_name}") ||
              if send(association.foreign_key)
                association.parent(self).tap do |object|
                  send("#{association_name}=", object)
                end
              end
          end

          define_method "#{association_name}=" do |associated_object|
            associated_object.tap do
              instance_variable_set(:"@#{association_name}", associated_object)
              send "#{association.foreign_key}=", associated_object.try(:id)
            end
          end
        end
      end
    end
  end
end
