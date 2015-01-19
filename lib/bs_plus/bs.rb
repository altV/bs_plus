require 'active_support'
require 'active_support/cache'
require 'active_support/core_ext/numeric'
require 'hashie'

module BsPlus
  class Bs
    FileCache = ActiveSupport::Cache::FileStore.new "#{Dir.home}/.browserstack_plus/cache"
    PopularBrowsers = ['ie']
    class <<self
      def list
        FileCache.fetch('bs.list', expires_in: 24.hours) {
          @list ||= RestClient.get("https://#{Config.fetch(:username)}:#{Config.fetch(:password)}"\
                                   "@www.browserstack.com/automate/browsers.json").
            tap! {|e| JSON.parse e}.
            map {|e| Hashie::Mash.new e}}
      end
    end
  end
end
