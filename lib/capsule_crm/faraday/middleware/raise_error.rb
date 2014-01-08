module CapsuleCRM
  module Faraday
    module Middleware
      class RaiseError < ::Faraday::Response::Middleware
        def on_complete(env)
          return if env[:status] < 400
          raise CapsuleCRM::Errors.class_for_error_code(env[:status]).
            new(env[:response])
        end
      end
    end
  end
end