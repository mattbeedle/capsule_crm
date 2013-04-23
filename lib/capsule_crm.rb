require 'active_model'
require 'faraday'
require 'virtus'
require 'capsule_crm/address'
require 'capsule_crm/connection'
require 'capsule_crm/email'
require 'capsule_crm/phone'
require 'capsule_crm/website'
require 'capsule_crm/hash_helper'
require 'capsule_crm/results_proxy'
require 'capsule_crm/errors/record_invalid'
require 'capsule_crm/contacts'
require 'capsule_crm/contactable'
require 'capsule_crm/configuration'
require 'capsule_crm/organization'
require 'capsule_crm/person'
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
