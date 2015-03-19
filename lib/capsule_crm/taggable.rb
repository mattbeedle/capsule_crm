module CapsuleCRM
  module Taggable
    extend ActiveSupport::Concern

    def tags
      tags = CapsuleCRM::Connection.get(
        "/api/#{api_singular_name}/#{id}/tag"
      )['tags']['tag']
      tags = [tags] if tags.is_a? Hash
      tags.map { |item| CapsuleCRM::Tag.new(item) }
    end

    def add_tag(tag_name)
      if id
        CapsuleCRM::Connection.post(
          "/api/#{api_singular_name}/#{id}/tag/#{URI.encode(tag_name)}"
        )
      end
    end

    def remove_tag(tag_name)
      if id
        CapsuleCRM::Connection.delete(
          "/api/#{api_singular_name}/#{id}/tag/#{URI.encode(tag_name)}"
        )
      end
    end

    def api_singular_name
      class_name = self.class.superclass.to_s unless self.class.superclass == Object
      class_name ||= self.class.to_s
      class_name.demodulize.downcase.singularize
    end
  end
end
