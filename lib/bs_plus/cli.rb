require 'thor'
require 'rest-client'
require 'json' unless defined? JSON # wtf is can't activate json-1.8.0, already activated json-1.8.1 (Gem::LoadError)
require 'parallel'
require 'bs_plus/browser'
require 'bs_plus/config'
require 'os'

module BsPlus
  class Cli < Thor
    desc 'list', 'List currently available browsers'
    def list
      puts 'browser browser_version os os_version device'
      puts '--------------------------------------------'
      Browser.all.each {|e| puts e }
    end

    BrowsersOption = {
      'desktop'  => Browser::Desktop,
      'ies'      => Browser::IEs,
      'androids' => Browser::Androids,
      'mobile'   => Browser::Mobile,
      'popular'  => Browser::Popular,
    }

    desc 'get WHAT [-b BROWSERS]', "takes snapshot(s). Browsers: #{BrowsersOption.keys.to_sentence} or one from 'bs list'"
    method_option :browsers, default: 'desktop', aliases: '-b',
      desc:"#{BrowsersOption.keys.to_sentence} or one from 'bs list'"
    def get url
      url = "http://#{url}" unless url[/http/]

      BsPlus.with_tunnel {
        (BrowsersOption[options[:browsers]] ||
         Browser.parse(options[:browsers]).take(1)).
          tap {|e| puts "Snapshotting with #{e.size} browsers:"}.
          tap!{|e| Parallel.map(e, in_threads: 5) {|b| b.snapshot url}} }
    end

    desc 'live URL -b BROWSER', "Opens browser on browserstack. Browser one from 'bs list' by regex"
    method_option :browser, required: true, aliases: '-b', desc:"Browser one from 'bs list' by regex"
    def live url
      url = "http://#{url}" unless url[/http/]

      BsPlus.with_tunnel {
        (Browser.parse(options[:browser]).first || (raise %Q[#{Browser.all.map(&:to_s).join("\n")}]+"\nCouldn't find browser in the list." )).
          tap {|e| puts "Opening with #{e}. Please log in to BrowserStack"}.
          tap!{|b| Launchy.open "https://www.browserstack.com/automate"
                   b.new_session do |browser|
                     browser.visit url
                     loop { browser.has_title?('.'); sleep 30 }
                   end } }
    end

    desc 'tunnel', 'Runs BrowserStackLocal binary with your key and --automate flag'
    def tunnel detach = false
      #Process.detach
      system File.join Kernel.__dir__, '../../bin', "BrowserStackLocal#{case
      when OS.windows? then 'Windows'; when OS.linux? then 'Linux'; when OS.mac? then 'Mac'; end
      } -force -onlyAutomate -forcelocal #{Config.fetch(:password)}"
    end
  end
end
