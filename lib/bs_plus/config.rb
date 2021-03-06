require 'yaml'
require 'highline'
require 'active_support/core_ext/hash'

class BsPlus::Config
  HomePath  = File.expand_path '~/.browserstack-plus'
  LocalPath = File.expand_path './.browserstack-plus'

  class <<self
  def init
    fetch(:username) {HighLine.new.ask('Please enter your browserstack username').to_s}

    fetch(:password) {HighLine.new.ask('Please enter your password') {|h|
                                       h.echo = false  }.to_s}
  end

  OtherDefaults =
    { }


  def home_config
    YAML.load_file(HomePath ).deep_symbolize_keys rescue {}      end

  def local_config
    YAML.load_file(LocalPath).deep_symbolize_keys rescue {}      end

  def all
    OtherDefaults.merge(home_config).merge(local_config)         end

  def fetch key, &blk
    unless block_given?
      all.fetch key
    else
      all.fetch key do
        value = yield
        write key, value
        value
      end
    end
  end

  def write key, value
    FileUtils.touch(HomePath) unless File.exists? HomePath
    write_config_file HomePath, home_config.merge({key => value})
  end

  def write_config_file path, hash
    File.open(HomePath, 'r+') { |f| YAML.dump hash.deep_stringify_keys, f }
  end

  def method_missing key
    fetch key
  end
end
end
