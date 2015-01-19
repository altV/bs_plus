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
  property :browser
  property :browser_version
  property :os
  property :os_version
  property :device

  FileCache = ActiveSupport::Cache::FileStore.new "#{Dir.home}/.browserstack_plus/cache"

  def self.all
    FileCache.fetch('browser.list', expires_in: 24.hours) {
      @list ||= RestClient.get("https://#{Config.fetch(:username)}:#{Config.fetch(:password)}"\
                               "@www.browserstack.com/automate/browsers.json").
        tap! {|e| JSON.parse e}.
        map {|e| new e}}
  end

  Popular = [
    new({browser: 'ie', browser_version: '7.0', os: 'Windows', os_version: 'XP'}),
  ]

  IEs = all.select {|e| e.browser[/ie/i]}


  def snapshot url
    # Input capabilities
    caps = Selenium::WebDriver::Remote::Capabilities.new.tap {|c|
      self.stringify_keys.select{|k,v| v}.each {|k,v| c[k] = v}
      c["browserstack.debug"] = "true"
      c["name"]               = "Running BrowserStack from command line"
    }

    driver = Selenium::WebDriver.for(:remote,
      url: "https://#{Config.fetch(:username)}:#{Config.fetch(:password)}"\
           "@hub.browserstack.com/wd/hub",
      desired_capabilities: caps)

    puts "Starting #{self}"
    driver.navigate.to url
    puts "Reached #{driver.title} from #{self}, saving screenshot"
    driver.save_screenshot(file = CGI.escape("#{url}__#{self}.png"))
    driver.quit
    puts "Done #{self}"
    Launchy.open "./#{file}"
  end

  def to_s
    "#{browser}#{browser_version}"\
    "(#{os}-#{os_version}#{':' + device if device})"
  end
end
end
