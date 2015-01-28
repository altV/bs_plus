require 'bs_plus/core_ext'
require 'bs_plus/version'
require 'bs_plus/config'
require 'childprocess'
require 'os'
BsPlus::Config.init # will ask for username/password if not present, hehe

require 'bs_plus/cli'

module BsPlus
  def self.with_tunnel
    p = ChildProcess.build File.expand_path(File.join(Kernel.__dir__, '../bin', "BrowserStackLocal#{case
    when OS.windows? then 'Windows'; when OS.linux? then 'Linux'; when OS.mac? then 'Mac'; end}")),
            '-force', '-forcelocal', Config.fetch(:password)
    p.io.inherit!
    p.start
    sleep 0.5
    raise "Problem with tunnel" unless p.alive?
    yield
  ensure
    p.stop# unless p.alive?
  end
end
