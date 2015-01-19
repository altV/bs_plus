require 'thor'
require 'rest-client'
require 'json'
require 'parallel'

module BsPlus
  class Cli < Thor
    desc 'list', 'List currently available browsers'
    def list
      puts 'browser browser_version os os_version device'
      puts '--------------------------------------------'
      Browser.all.each {|e| puts e }
    end

    desc 'get WHAT [-b BROWSERS]', 'takes snapshot(s)'
    method_option :browsers, default: 'popular', aliases: '-b'
    def get url
      url = "http://#{url}" unless url[/http/]

      case options[:browsers]
      when 'popular' then Browser::Popular
      when 'ies'     then Browser::IEs
      else
        Browser.parse options[:browsers]
      end.
        tap {|e| puts "Snapshotting with #{e.size} browsers:"}.
        tap!{|e| Parallel.map(e, in_threads: 5) {|b| b.snapshot url}}
    end
  end
end
