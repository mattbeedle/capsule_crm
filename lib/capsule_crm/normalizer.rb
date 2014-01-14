module CapsuleCRM
  class Normalizer
    attr_reader :klass, :options

    def initialize(klass, options = {})
      @klass   = klass
      @options = options
    end

    def normalize(attrs = {})
      subclasses? ? normalize_subclass(attrs) : normalize_single(attrs)
    end

    def normalize_collection(attrs)
      if subclasses?
        normalize_subclass_collection(attrs)
      else
        normalize_standard_collection(attrs)
      end
    end

    private

    def root
      @root ||= options[:root] || klass.serializable_options.root
    end

    def collection_root
      @collection_root ||= options[:collection_root] ||
        klass.serializable_options.collection_root
    end

    def attribute_to_assign
      @attribute_to_assign ||= klass.serializable_options.attribute_to_assign
    end

    def normalize_subclass(attrs)
      hash_helper.underscore_keys!(attrs[attrs.keys.first])
      klass.child_classes[attrs.keys.first].constantize.new(
        attrs[attrs.keys.first]
      )
    end

    def normalize_single(attrs)
      hash_helper.underscore_keys!(attrs[root.to_s])
      klass.new(attrs[root.to_s])
    end

    def normalize_subclass_collection(attrs)
      [].tap do |objects|
        attrs[collection_root.to_s].each do |key, value|
          next unless klass.child_classes.keys.include?(key)
          if value.is_a?(Hash)
            objects << klass.child_classes[key].constantize.
              new(hash_helper.underscore_keys(value))
          else
            value.each do |attributes|
              objects << klass.child_classes[key].constantize.
                new(hash_helper.underscore_keys(attributes))
            end
          end
        end
      end
    end

    def normalize_standard_collection(attrs)
      return [] unless attrs[collection_root.to_s][root.to_s]
      [attrs[collection_root.to_s][root.to_s]].flatten.map do |singular|
        if attribute_to_assign
          klass.new attribute_to_assign => singular
        else
          klass.new hash_helper.underscore_keys(singular)
        end
      end
    end

    def subclasses?
      root.is_a?(Array)
    end

    def hash_helper
      @hash_helper ||= CapsuleCRM::HashHelper
    end
  end
end
