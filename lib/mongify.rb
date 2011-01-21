#
# Mongify's core functionality
#
require 'active_support/core_ext'
require 'active_record'

require 'mongify/ui'
require 'mongify/exceptions'
require 'mongify/translation'
require 'mongify/configuration'
require 'mongify/database'

module Mongify # :nodoc:
  class << self
    # Handles setting root for the application
    def root=(value)
      @root = value
    end
    #Raises RootMissing if you attempt to call root without setting it
    def root
      raise RootMissing, "Root not configured" if @root.nil?
      @root
    end
  end
end