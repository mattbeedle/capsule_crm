module CapsuleCRM
  class Serializer
    attr_reader :object, :options

    def initialize(object, options = {})
      @object  = object
      @options = options
    end

    def serialize
      @serialized ||= { root => build_attributes_hash }.stringify_keys
    end

    private

    def additional_methods
      @additional_methods ||= options[:additional_methods] || []
    end

    def excluded_keys
      @excluded_keys ||= options[:excluded_keys] || []
    end

    def root
      @root ||= options[:root] ||
        object.class.to_s.demodulize.downcase.singularize
    end

    def build_attributes_hash
      CapsuleCRM::HashHelper.camelize_keys(cleaned_attributes)
    end

    def cleaned_attributes
      attributes.delete_if do |key, value|
        value.blank? || key.to_s == 'id' || excluded_keys.include?(key)
      end
    end

    def attributes
      object.attributes.dup.tap do |attrs|
        attrs.each do |key, value|
          attrs[key] = value.to_s(:db) if value.is_a?(Date)
        end
        additional_methods.each do |method|
          attrs.merge!(method => object.send(method).to_capsule_json)
        end
        object.class.belongs_to_associations.each do |name, association|
          attrs.merge!(association.serializable_key => object.send(name).try(:id))
        end
      end
    end
  end
end