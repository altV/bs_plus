require 'thor'
require 'rest-client'
require 'json'

module BsPlus
  class Cli < Thor
    desc 'list', 'List currently available browsers'
    def list
      puts 'browser browser_version os os_version device'
      puts '--------------------------------------------'
      Bs.list.map {|e| "#{e.browser}#{e.browser_version
                   } (#{e.os}/#{e.os_version}#{' - ' + e.device if e.device})"}.
        each {|e| puts e }
    end
  end
end
