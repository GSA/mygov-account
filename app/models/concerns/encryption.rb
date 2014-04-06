require 'active_support/concern'

module Encryption  
  extend ActiveSupport::Concern

  def key
    key = Rails.configuration.database_configuration['encryption_key']
    # if in production. require key to be set.
    if Rails.env.production?
      raise 'Must set token key!!' unless key
      key
    else
      key
    end
  end

end