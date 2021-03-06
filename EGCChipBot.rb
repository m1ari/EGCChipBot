#!/usr/bin/env ruby
require 'bundler/setup'

require_relative 'lib/exchanges'
require_relative 'lib/evergreencoin'
require_relative 'lib/logger'
require_relative 'lib/settings'

# Load settings from EGCChipBot.yaml
Settings.load! "EGCChipBot.yaml"

bot = Cinch::Bot.new do
  configure do |c|
    c.server = Settings.irc[:host]

    if Settings.irc[:use_ssl]
      c.ssl.use = true
      c.port = Settings.irc[:ssl_port]
    else
      c.port = Settings.irc[:port]
    end

    # TODO Pull from config file
    #config.plugins.options[Logger] = {
      #:logdir => "/tmp/logs"
    #}

    c.channels = Settings.irc[:channels]
    c.nick = Settings.irc[:nick]
    c.user = Settings.irc[:user]
    c.realname = Settings.irc[:name]
    c.plugins.plugins = [EGC, Exchanges, Logger]
  end

end

bot.start
