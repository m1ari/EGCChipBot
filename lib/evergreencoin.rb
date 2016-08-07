#!/usr/bin/env ruby
require 'cinch'
require 'pp'

class EGC
  include Cinch::Plugin

  # All commands in this module are prefixed with !egc <command>
  set :prefix, /!egc /

  # Provide help information
  match "help", method: :help
  def help(m)
    m.reply "!egc info - Current EGC state"
    m.reply "!egc hash <id> - Block hash of block <id>"
  end

  match "info", method: :info
  def info(m)
  end

  match "block ([0-9]+)", method: :block
  def block(m, block)

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
    Channel("#ukhasnet-test").send out.join(" | ")
  end

  #timer 10, method: :bing
  def bing()
    Channel("#ukhasnet-test").send(Time.now.to_s)
    #m.reply "Bing Bong"
  end

end
