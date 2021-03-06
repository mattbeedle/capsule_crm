require 'active_model'
require 'active_support/core_ext/string/inflections'
require 'faraday'
require 'faraday_middleware'
require 'virtus'
require 'capsule_crm/gettable'
require 'capsule_crm/taggable'
require 'capsule_crm/associations'
require 'capsule_crm/connection'
require 'capsule_crm/normalizer'
require 'capsule_crm/persistence'
require 'capsule_crm/querying'
require 'capsule_crm/serializer'
require 'capsule_crm/serializable'
require 'capsule_crm/inspector'

require 'capsule_crm/address'
require 'capsule_crm/attachment'
require 'capsule_crm/case'
require 'capsule_crm/country'
require 'capsule_crm/currency'
require 'capsule_crm/email'
require 'capsule_crm/history'
require 'capsule_crm/party'
require 'capsule_crm/phone'
require 'capsule_crm/tag'
require 'capsule_crm/task'
require 'capsule_crm/user'
require 'capsule_crm/website'
require 'capsule_crm/hash_helper'
require 'capsule_crm/results_proxy'
require 'capsule_crm/errors'
require 'capsule_crm/errors/association_type_mismatch'
require 'capsule_crm/errors/record_invalid'
require 'capsule_crm/errors/record_not_saved'
require 'capsule_crm/errors/response_error'
require 'capsule_crm/contacts'
require 'capsule_crm/contactable'
require 'capsule_crm/configuration'
require 'capsule_crm/custom_field'
require 'capsule_crm/custom_field_definition'
require 'capsule_crm/opportunity'
require 'capsule_crm/organization'
require 'capsule_crm/participant'
require 'capsule_crm/person'
require 'capsule_crm/milestone'
require 'capsule_crm/task_category'
require 'capsule_crm/track'
require 'capsule_crm/version'
require 'capsule_crm/faraday/middleware/raise_error'

module CapsuleCRM

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration = CapsuleCRM::Configuration.new
    yield(self.configuration)
    self.configuration
  end

  def self.log(message, level = :debug)
    if self.configuration.perform_logging
      self.configuration.logger.send(level, message)
    end
  end
end
