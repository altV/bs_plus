require 'thor'
require 'rest-client'
require 'json'
require 'parallel'
require 'bs_plus'
require 'bs_plus/browser'

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

    desc 'get WHAT [-b BROWSERS]', 'takes snapshot(s)'
    method_option :browsers, default: 'desktop', aliases: '-b',
      desc:"#{BrowsersOption.keys.to_sentence} or one from 'bs list'"
    def get url
      url = "http://#{url}" unless url[/http/]

      (BrowsersOption[options[:browsers]] ||
       Browser.parse(options[:browsers])).
        tap {|e| puts "Snapshotting with #{e.size} browsers:"}.
        tap!{|e| Parallel.map(e, in_threads: 5) {|b| b.snapshot url}}
    end
  end
end
