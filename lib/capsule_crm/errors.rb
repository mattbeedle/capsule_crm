require_relative 'errors/response_error'

module CapsuleCRM
  module Errors
    BAD_REQUEST           = 400
    NOT_AUTHORIZED        = 401
    NOT_FOUND             = 404
    INTERNAL_SERVER_ERROR = 500

    class << self
      def error_constants
        self.constants.each_with_object({}) do |name, hash|
          next if (code = Errors.const_get(name)).is_a?(Class)
          hash[name] = code
        end
      end

      def class_name_for_error_name(name)
        name.to_s.titleize.gsub(' ', '')
      end

      def class_for_error_name(name)
        class_name = class_name_for_error_name(name)
        if const_defined?(class_name)
          CapsuleCRM::Errors.const_get(class_name)
        else
          CapsuleCRM::Errors::InternalServerError
        end
      end

      def class_for_error_code(code)
        name = error_constants.select { |k, v| v == code }.keys.first
        if name.present?
          class_for_error_name(name)
        else
          CapsuleCRM::Errors::InternalServerError
        end
      end
    end
  end
end

CapsuleCRM::Errors.error_constants.each do |name, code|
  klass = Class.new(CapsuleCRM::Errors::ResponseError)
  klass.send(:define_method, :code) { code }
  klass_name = CapsuleCRM::Errors.class_name_for_error_name(name)
  CapsuleCRM::Errors.const_set(klass_name, klass)
end
