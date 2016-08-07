#!/usr/bin/env ruby
require 'cinch'
require_relative 'evergreencoin_rpc'

class EGC
  include Cinch::Plugin

  def initialize(*args)
    super
    @rpc = EverGreenCoinRPC.new("http://#{Settings.wallet[:user]}:#{Settings.wallet[:password]}@#{Settings.wallet[:host]}:#{Settings.wallet[:port]}")
  end

  # All commands in this module are prefixed with !egc <command>
  set :prefix, /!egc /

  # Provide help information
  match "help", method: :help
  def help(m)
    m.reply "!egc info        - Shows some current EGC state"
    m.reply "!egc block <id>  - Gets the hash for block <id>"
  end

  match "info", method: :info
  def info(m)
    info=@rpc.getinfo
    m.reply "Current block #{info["blocks"]}"

  end

  match /block ([0-9]+)/, method: :block
  def block(m, block)
    hash=@rpc.getblockhash(block.to_i)
    m.reply "hash for block #{block} is #{hash}"
  end

  def execute(m)
    m.reply "Execute"
  end

  listen_to :exchange_update
  def listen(m, result)
    #19:05 <@StevenSaxton> c-cex 0.00006499 | bittrex 0.00006399 | cryptopia 0.00006490 | yobit 0.00006150 |
    out = Array.new
    result.each do |r|
      out.push "%s %0.8f" %[r[:name], r[:last]]
    end
    Settings.irc[:channels].each do |chan|
      puts "Sending to #{chan}"
      Channel(chan).send out.join(" | ")
    end
  end

  #timer 10, method: :bing
  def bing()
    Channel("#ukhasnet-test").send(Time.now.to_s)
    #m.reply "Bing Bong"
  end

end
