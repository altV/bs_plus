require 'active_support'
require 'active_support/cache'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/string'
require 'selenium-webdriver'
require 'launchy'
require 'hashie'
require 'cgi'
require 'capybara'
require 'bs_plus/config'

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
      @list ||= RestClient.get("https://#{Config.fetch(:username)}:#{Config.fetch(:password)}"\
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


  def new_session options={}
    options.reverse_merge! local: true
    caps = Selenium::WebDriver::Remote::Capabilities.new.tap {|c|
      self.stringify_keys.select{|k,v| v}.each {|k,v| c[k] = v}
      c["browserstack.debug"] = 'true'
      c['browserstack.local'] = (!!options[:local]).to_s
      c['acceptSslCerts']     = 'true'
      c["name"]               = 'Running bs_plus from command line'
    }

    Capybara.register_driver(:"#{to_s}") { |app|
      Capybara::Selenium::Driver.new(app, browser: :remote,
        url: "https://#{Config.fetch(:username)}:#{Config.fetch(:password)}"\
             "@hub-eu.browserstack.com/wd/hub",
        desired_capabilities: caps) }

    yield (s = Capybara::Session.new(:"#{to_s}"))
  ensure
    s.driver.quit
  end

  def snapshot url
    new_session do |browser|
      puts "Starting #{self}"
      browser.visit url
      puts "Reached #{browser.title} from #{self}, saving screenshot"
      browser.save_screenshot file = CGI.escape("#{url}__#{self}.png")
      puts "Done #{self}"
      Launchy.open "./#{file}"
    end
  rescue => e
    puts "#{e.inspect} from #{self}"
  end

  def to_s
    "#{browser}#{browser_version}"\
    "(#{os}-#{os_version}#{':' + device if device})"
  end

  def self.parse browser_string
    all.select {|b| b.to_s[Regexp.new browser_string, 'i']}
  end

  def self.logins
    @logins ||= begin
      File.expand_path('~/.loginfile.rb').tap! {|home_path|  load home_path  if File.exists? home_path }
      File.expand_path('./.loginfile.rb').tap! {|local_path| load local_path if File.exists? local_path }

      (defined?(LoginsGlobal) ? LoginsGlobal : {}).merge(defined?(LoginsLocal) ? LoginsLocal : {})
    end
  end

  def self.actions
    @actions ||= begin
      File.expand_path('~/.loginfile.rb').tap! {|home_path|  load home_path  if File.exists? home_path }
      File.expand_path('./.loginfile.rb').tap! {|local_path| load local_path if File.exists? local_path }

      (defined?(ActionsGlobal) ? ActionsGlobal : {}).merge(defined?(ActionsLocal) ? ActionsLocal : {})
    end
  end






  def raw_selenium_session options={}
    options.reverse_merge! local: true
    caps = Selenium::WebDriver::Remote::Capabilities.new.tap {|c|
      self.stringify_keys.select{|k,v| v}.each {|k,v| c[k] = v}
      c["browserstack.debug"] = 'true'
      c['browserstack.local'] = (!!options[:local]).to_s
      c['acceptSslCerts']     = 'true'
      c["name"]               = 'Running bs_plus from command line'
    }

    driver = Selenium::WebDriver.for(:remote,
      url: "https://#{Config.fetch(:username)}:#{Config.fetch(:password)}"\
           "@hub.browserstack.com/wd/hub",
      desired_capabilities: caps)
  end

end
end
