require_relative 'has_many_association'
require_relative 'has_many_proxy'

module CapsuleCRM
  module Associations
    module HasMany
      extend ActiveSupport::Concern

      module ClassMethods

        # Public: Add the setter and getter methods for a has_many association.
        #
        # association_name  - The String name of the associated collection
        # options:          - The Hash of options (default: {}):
        #                     :class_name - The String name of the class used in the
        #                     association
        #                     :source - the String method name used by the
        #                     object on the belongs_to side of the association
        #                     to set this object
        #
        # Examples
        #
        # class CapsuleCRM::Organizatio
        #   include CapsuleCRM::Associations::HasMany
        #
        #   has_many :people, class_name: 'CapsuleCRM::Person', source: :person
        # end
        #
        # organization = CapsuleCRM::Organization.find(1)
        # organization.people
        # => [CapsuleCRM::Person, CapsuleCRM::Person, ...]
        #
        # person = CapsuleCRM::Organization.find(5)
        # organization.people= [person]
        # organization.people
        # => [person]
        def has_many(association_name, options = {})
          association = CapsuleCRM::Associations::HasManyAssociation.
            new(association_name, self, options)
          self.associations[association_name] = association

          if options[:embedded]
            define_method "save_#{association_name}" do
              unless send(association_name).empty?
                send(association_name).save
              end
            end

            class_eval do
              after_save :"save_#{association_name}" if respond_to?(:after_save)
              private :"save_#{association_name}"
            end
          end

          define_method association_name do
            instance_variable_get(:"@#{association_name}") ||
              instance_variable_set(:"@#{association_name}", association.proxy(self))
          end

          define_method "#{association_name}=" do |associated_objects|
            instance_variable_set :"@#{association_name}",
              association.proxy(self, associated_objects)
          end
        end
      end
    end
  end
end
