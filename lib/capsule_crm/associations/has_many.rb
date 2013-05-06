require 'capsule_crm/associations/has_many_proxy'

module CapsuleCRM
  module Associations
    module HasMany
      extend ActiveSupport::Concern

      module ClassMethods

        # Public: Add the setter and getter methods for a has_many association.
        #
        # association_name  - The String name of the associated collection
        # options:          - The Hash of options (default: {}):
        #                   class_name: The String name of the class used in the
        #                   association
        #
        # Examples
        #
        # class CapsuleCRM::Organizatio
        #   include CapsuleCRM::Associations::HasMany
        #
        #   has_many :people, class_name: 'CapsuleCRM::Person'
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
          define_method association_name do
            instance_variable_get("@#{association_name}") ||
              CapsuleCRM::Associations::HasManyProxy.new(
                options[:class_name].constantize.
                send("for_#{self.class.to_s.demodulize.downcase}", id)
              ).tap do |proxy|
                instance_variable_set "@#{association_name}", proxy
              end
          end

          define_method "#{association_name}=" do |associated_objects|
            instance_variable_set :"@#{association_name}",
              CapsuleCRM::Associations::HasManyProxy.new(associated_objects)
          end
        end
      end
    end
  end
end
