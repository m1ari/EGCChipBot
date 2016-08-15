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

end
