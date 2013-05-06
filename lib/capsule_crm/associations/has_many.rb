module CapsuleCRM
  module Associations
    module HasMany
      extend ActiveSupport::Concern

      module ClassMethods
        def has_many(association_name, options = {})

          define_method association_name do
            instance_variable_get "@#{association_name}"
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
