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

    def self.root(klass)
      klass.serializable_options.root
    end

    def self.collection_root(klass)
      klass.serializable_options.collection_root
    end

    def self.normalize(klass, attrs = {})
      CapsuleCRM::HashHelper.underscore_keys!(attrs[root(klass).to_s])
      klass.new(attrs[root(klass).to_s])
    end

    def self.serialize_collection(klass, collection)
      collection = collection.map { |item| item.to_capsule_json }
      { klass.serializable_options.plural => collection }
    end

    def self.normalize_collection(klass, json)
      json[collection_root(klass).to_s][root(klass).to_s].map do |singular|
        klass.new CapsuleCRM::HashHelper.underscore_keys(singular)
      end
    end

    def serialize_with_root
      { root => build_attributes_hash }.stringify_keys
    end

    def serialize_without_root
      build_attributes_hash
    end

    def root
      @root ||= options[:root] ||
        object.class.to_s.demodulize.downcase.singularize.camelize(:lower)
    end

    def collection_root
      @collection_root ||= options[:collection_root] || root.pluralize
    end

    private

    def include_root?
      @include_root ||= true unless options[:include_root] == false
    end

    def additional_methods
      @additional_methods ||= options[:additional_methods] || []
    end

    def excluded_keys
      @excluded_keys ||= options[:excluded_keys] || []
    end

    def build_attributes_hash
      CapsuleCRM::HashHelper.camelize_keys(cleaned_attributes)
    end

    def excluded_association_keys
      @excluded_association_keys ||=
        if object.class.respond_to?(:belongs_to_associations)
          object.class.belongs_to_associations.map do |name, association|
          association.foreign_key if association.inverse && association.inverse.embedded
        end.compact
        else
          []
        end
    end

    def cleaned_attributes
      attributes.delete_if do |key, value|
        value.blank? || key.to_s == 'id' || excluded_keys.include?(key) ||
          excluded_association_keys.include?(key.to_s)
      end
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
          attrs.merge!(method => object.send(method).to_capsule_json)
        end
        object.class.belongs_to_associations.each do |name, association|
          attrs.merge!(
            association.serializable_key => object.send(name).try(:id)
          ) unless association.serialize == false
        end if object.class.respond_to?(:belongs_to_associations)
      end
    end
  end
end