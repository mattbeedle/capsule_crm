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
          define_method association_name do
            instance_variable_get(:"@#{association_name}") ||
              CapsuleCRM::Associations::HasManyProxy.new(
                self, # parent
                options[:class_name].constantize, # target class
                options[:class_name].constantize.
                  send("_for_#{self.class.to_s.demodulize.downcase}", self.id),
                options[:source] # source
              ).tap do |proxy|
                instance_variable_set :"@#{association_name}", proxy
              end
            instance_variable_get :"@#{association_name}"
          end

          define_method "#{association_name}=" do |associated_objects|
            if associated_objects.is_a?(Hash)
              associated_objects = Array(options[:class_name].constantize.new(associated_objects[options[:class_name].demodulize.downcase]))
            end
            instance_variable_set :"@#{association_name}",
              CapsuleCRM::Associations::HasManyProxy.new(
                self, options[:class_name].constantize,
                associated_objects, options[:source]
              )
          end
        end
      end
    end
  end
end
