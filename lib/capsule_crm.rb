require 'active_model'
require 'faraday'
require 'virtus'
require 'capsule_crm/connection'
require 'capsule_crm/hash_helper'
require 'capsule_crm/results_proxy'
require 'capsule_crm/associations/belongs_to'
require 'capsule_crm/associations/has_many'
require 'capsule_crm/associations/has_many_proxy'
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
