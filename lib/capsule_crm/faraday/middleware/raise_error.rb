module CapsuleCRM
  module Faraday
    module Middleware
      class RaiseError < ::Faraday::Response::Middleware
        attr_writer :error_factory

        def on_complete(env)
          return if env[:status] < 400
          raise error_factory.error_from_env(env)
        end

        private

        def error_factory
          @error_factory ||= CapsuleCRM::Errors
        end
      end
    end
  end
end