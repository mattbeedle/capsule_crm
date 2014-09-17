module CapsuleCRM
  class Serializer
    attr_reader :object, :options

    def initialize(options = {})
      @options = options
    end

    def serialize(object)
      @object = object
      @serialized ||=
        if include_root?
          serialize_with_root
        else
          serialize_without_root
        end
    end

    def self.serialize_collection(klass, collection)
      collection = collection.map do |item|
        options = klass.serializable_options.dup
        options.include_root = false
        ::CapsuleCRM::Serializer.new(options).serialize(item)
      end
      { klass.serializable_options.root => collection }
    end

    def serialize_with_root
      { root => build_attributes_hash }.stringify_keys
    end

    def serialize_without_root
      build_attributes_hash
    end

    def root
      @root ||= options.root ||
        object.class.to_s.demodulize.downcase.singularize.camelize(:lower)
    end

    def collection_root
      @collection_root ||= options.collection_root || root.pluralize
    end

    private

    def include_root?
      @include_root ||= true unless options.include_root == false
    end

    def additional_methods
      @additional_methods ||= options.additional_methods || []
    end

    def excluded_keys
      @excluded_keys ||= options.excluded_keys || []
    end

    def build_attributes_hash
      CapsuleCRM::HashHelper.camelize_keys(cleaned_attributes)
    end

    def excluded_association_keys
      @excluded_association_keys ||=
        if object.class.respond_to?(:belongs_to_associations)
          object.class.belongs_to_associations.map do |name, association|
          association.foreign_key if association.inverse.try(:embedded)
        end.compact
        else
          []
        end
    end

    def cleaned_attributes
      attributes.delete_if do |key, value|
        value.blank? || (key.to_s == 'id' && exclude_id?) ||
          excluded_keys.include?(key) ||
          excluded_association_keys.include?(key.to_s)
      end
    end

    def exclude_id?
      @exclude_id ||= true unless options.exclude_id == false
    end

    # TODO OMG, clean this up!
    def attributes
      object.attributes.dup.tap do |attrs|
        attrs.each do |key, value|
          attrs[key] = value.to_s(:db) if value.is_a?(Date)
          if value.is_a?(DateTime)
            attrs[key] = value.strftime("%Y-%m-%dT%H:%M:%SZ")
          end
        end
        additional_methods.each do |method|
          unless object.send(method).blank?
            attrs.merge!(method => object.send(method).to_capsule_json)
          end
        end
        object.class.belongs_to_associations.each do |name, association|
          attrs.merge!(
            association.serializable_key => belongs_to_value(object, name)
          ) unless association.serialize == false
        end if object.class.respond_to?(:belongs_to_associations)
      end
    end

    def belongs_to_value(object, name)
      value = object.send(name)
      value = value.id if value.respond_to?(:id)
      value
    end
  end
end