require 'active_model'
require 'faraday'
require 'faraday_middleware'
require 'virtus'
require 'capsule_crm/attributes'
require 'capsule_crm/capsule_jsonable'
require 'capsule_crm/taggable'
require 'capsule_crm/collection'
require 'capsule_crm/associations'
require 'capsule_crm/address'
require 'capsule_crm/case'
require 'capsule_crm/connection'

require 'capsule_crm/attachment'
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
require 'capsule_crm/errors/record_invalid'
require 'capsule_crm/contacts'
require 'capsule_crm/contactable'
require 'capsule_crm/configuration'
require 'capsule_crm/custom_field'
require 'capsule_crm/opportunity'
require 'capsule_crm/organization'
require 'capsule_crm/participant'
require 'capsule_crm/person'
require 'capsule_crm/milestone'
require 'capsule_crm/version'

module CapsuleCRM

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration = CapsuleCRM::Configuration.new
    yield(self.configuration)
    self.configuration
  end
end
