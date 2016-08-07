#!/usr/bin/env ruby
require 'bundler/setup'

require_relative 'lib/exchanges'
require_relative 'lib/evergreencoin'
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

    c.channels = Settings.irc[:channels]
    c.nick = Settings.irc[:nick]
    c.user = Settings.irc[:user]
    c.realname = Settings.irc[:name]
    c.plugins.plugins = [EGC]
  end

end

Thread.new { PollExchanges.new(bot).start }
bot.start
