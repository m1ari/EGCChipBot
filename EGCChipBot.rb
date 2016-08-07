#!/usr/bin/env ruby
require 'cinch'

require_relative 'lib/exchanges'
require_relative 'lib/evergreencoin'
#require_relative 'lib/settings'

# Load settings from EGCChipBot.yaml
Settings.load! "EGCChipBot.yaml"

#pp Settings.irc

use_ssl = true

bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'chat.freenode.net'

    if use_ssl
      c.ssl.use = true
      c.port = 7070
    else
      c.port = 8000
    end

    c.channels = ["#ukhasnet-test"]
    c.nick = "EGCChip"
    c.realname = "EGC C.H.I.P bot"
    c.plugins.plugins = [EGC]
  end

  on :message, "hello" do |m|
    m.reply "Hello, #{m.user.nick}"
  end
end

Thread.new { PollExchanges.new(bot).start }
bot.start

# vim: tabstop=2 shiftwidth=2 expandtab
