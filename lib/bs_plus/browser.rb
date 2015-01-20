require 'active_support'
require 'active_support/cache'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/string'
require 'selenium-webdriver'
require 'launchy'
require 'hashie'
require 'cgi'

module BsPlus
class Browser < Hashie::Dash
  include Hashie::Extensions::Dash::IndifferentAccess
  property :browser
  property :browser_version
  property :os
  property :os_version
  property :device

  FileCache = ActiveSupport::Cache::FileStore.new "#{Dir.home}/.browserstack_plus/cache"

  def self.all
    FileCache.fetch('browser.list', expires_in: 24.hours) {
      @list ||= RestClient.get("https://#{BsPlus::Config.fetch(:username)}:#{BsPlus::Config.fetch(:password)}"\
                               "@www.browserstack.com/automate/browsers.json").
        tap! {|e| JSON.parse e}.
        map {|e| new e}}
  end

  Desktop = [
    new({browser: 'ie', browser_version: '8.0',  os: 'Windows', os_version: '7'}),
    new({browser: 'ie', browser_version: '9.0',  os: 'Windows', os_version: '7'}),
    new({browser: 'ie', browser_version: '10.0', os: 'Windows', os_version: '7'}),
    new({browser: 'ie', browser_version: '11.0', os: 'Windows', os_version: '7'}),
    new({browser: 'firefox', browser_version: '30.0', os: 'Windows', os_version: '7'}),
    new({browser: 'chrome',  browser_version: '33.0', os: 'Windows', os_version: '7'}),
  ]
  IEs      = all.select {|e| e.browser[/ie/i]}
  Androids = all.select {|e| e.os[/android/i]}
  Mobile   = [
    new({browser: 'android', browser_version: '', os: 'android', os_version: '4.4', device: 'Samsung Galaxy S5'}),
    new({browser: 'iphone', browser_version: '', os: 'ios', os_version: '7.0', device: 'iPhone 5C'}),
  ]
  Popular = (Desktop + Mobile)

  def snapshot url
    # Input capabilities
    caps = Selenium::WebDriver::Remote::Capabilities.new.tap {|c|
      self.stringify_keys.select{|k,v| v}.each {|k,v| c[k] = v}
      c["browserstack.debug"] = "true"
      c["name"]               = "Running BrowserStack from command line"
    }

    driver = Selenium::WebDriver.for(:remote,
      url: "https://#{BsPlus::Config.fetch(:username)}:#{BsPlus::Config.fetch(:password)}"\
           "@hub.browserstack.com/wd/hub",
      desired_capabilities: caps)

    begin
      puts "Starting #{self}"
      driver.navigate.to url
      puts "Reached #{driver.title} from #{self}, saving screenshot"
      driver.save_screenshot(file = CGI.escape("#{url}__#{self}.png"))
      driver.quit
      puts "Done #{self}"
      Launchy.open "./#{file}"
    rescue => e
      puts "#{e.inspect} from #{self}"
    end
  end

  def to_s
    "#{browser}#{browser_version}"\
    "(#{os}-#{os_version}#{':' + device if device})"
  end
end
end
