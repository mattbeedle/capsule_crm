module CapsuleCRM
  module Persistence
    module Persistable
      extend ActiveSupport::Concern

      def self.included(base)
        base.send :include, CapsuleCRM::Persistence::Configuration
        base.extend CapsuleCRM::Persistence::Persistable::ClassMethods
      end

      module ClassMethods
        def create(attributes = {})
          new(attributes).tap(&:save)
        end

        def create!(attributes = {})
          new(attributes).tap(&:save!)
        end
      end

      def save
        if valid?
          new_record? ? create_record : update_record
        else
          false
        end
      end

      def save!
        if valid?
          new_record? ? create_record : update_record
        else
          raise CapsuleCRM::Errors::RecordInvalid.new(self)
        end
      end

      def update_attributes(attributes = {})
        self.attributes = attributes
        save
      end

      def update_attributes!(attributes = {})
        self.attributes = attributes
        save!
      end

      def new_record?
        !id
      end

      def persisted?
        !new_record?
      end

      def create_record
        self.attributes = CapsuleCRM::Connection.post(
          build_create_path, to_capsule_json
        )
        self
      end

      def build_create_path
        "/api/#{self.connection_options.create.call(self)}"
      end

      def build_update_path
        "/api/#{self.connection_options.update.call(self)}"
      end

      def update_record
        CapsuleCRM::Connection.put(build_update_path, to_capsule_json)
        self
      end
    end
  end
end