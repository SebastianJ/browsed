require "selenium-webdriver"

require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"

require "agents"

require "browsed/version"

require "browsed/constants"
require "browsed/errors"
require "browsed/configuration"

require "browsed/manager"

require "browsed/proxies/chrome/proxy_authentication"
require "browsed/proxies/proxy_chain"

require "browsed/proxies"
require "browsed/browser"
require "browsed/phantomjs"
require "browsed/firefox"
require "browsed/chrome"
require "browsed/client"

if !Hash.instance_methods(false).include?(:symbolize_keys)
  require "browsed/extensions/hash"
end

module Browsed
  
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= ::Browsed::Configuration.new
  end

  def self.reset
    @configuration = ::Browsed::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
  
end
