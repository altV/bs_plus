require 'bs_plus/version'
require 'bs_plus/cli'
require 'bs_plus/bs'
require 'bs_plus/core_ext'
require 'bs_plus/config'

module BsPlus
  Config.init # will ask for username/password if not present
end
