#!/usr/bin/env ruby
require 'cinch'
require 'json'
require 'open-uri'

class Exchanges
  include Cinch::Plugin

  def initialize(*args)
    super
    @exchanges_last = poll_all
  end

  def poll_bittrex
    # Bittrex (https://bittrex.com/api/v1.1/public/getticker?market=btc-egc)
    bittrex = JSON.parse(open("https://bittrex.com/api/v1.1/public/getticker?market=btc-egc").read)
    return  {:name => "Bittrex", :last => bittrex["result"]["Last"]}
  end

  def poll_ccex
    # c-cex (https://c-cex.com/t/egc-btc.json)
    ccex = JSON.parse(open("https://c-cex.com/t/egc-btc.json").read)
    return {:name => "C-Cex", :last => ccex["ticker"]["lastprice"]}
  end

  def poll_cryptopia
    # cryptopia (https://www.cryptopia.co.nz/api/GetMarket/2788/24)
    tradePairId = 2788 # from https://www.cryptopia.co.nz/api/GetMarkets
    hours=24
    cryptopia = JSON.parse(open("https://www.cryptopia.co.nz/api/GetMarket/#{tradePairId}/#{hours}").read)
    return {:name => "Cryptopia", :last => cryptopia["Data"]["LastPrice"]}
  end

  def poll_yobit
    # yobit (https://yobit.net/api/2/egc_btc/ticker)
    yobit = JSON.parse(open("https://yobit.net/api/2/egc_btc/ticker").read)
    return {:name => "Yobit", :last => yobit["ticker"]["last"]}
  end

  def poll_all
    threads = Array.new
    threads << Thread.new{poll_bittrex}
    threads << Thread.new{poll_ccex}
    threads << Thread.new{poll_cryptopia}
    threads << Thread.new{poll_yobit}
    
    exchange = Array.new
    threads.each do |t|
      exchange << t.value
    end
    return exchange
  end

  def exchanges_to_s(data)
    out = Array.new
    data.each do |r|
      out.push "%s %0.8f" %[r[:name], r[:last]]
    end

    return out.join(" | ")
  end

  match "markets", method: :markets
  def markets(m)
    exchanges = poll_all
    m.reply exchanges_to_s(exchanges)
    @exchanges_last = exchanges
  end

  timer 1800, method: :daily_update
  def daily_update
    #19:05 <@StevenSaxton> c-cex 0.00006499 | bittrex 0.00006399 | cryptopia 0.00006490 | yobit 0.00006150 |

    # Get Exchange data
    exchanges = poll_all

    # TODO, Compare exchanges and @exchanges_last and set flag if over ??%

    # TODO update to print if flag above is set
    if Time.now.utc.hour==00 and Time.now.min >= 15 and Time.now.min < 45
      Settings.irc[:channels].each do |chan|
        puts "Sending to #{chan}"
        Channel(chan).send exchanges_to_s(exchanges)
      end
      @exchanges_last = exchanges
    end
  end

end

