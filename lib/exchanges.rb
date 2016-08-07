#!/usr/bin/env ruby
require 'json'
require 'open-uri'

class PollExchanges
  def initialize(bot)
    @bot = bot
    @startup=true
  end

  def start
    sleep 60 # Give the bot a chance to startup, allowing us to print the exchange state on startup
    while true
      # Show the state on startup or if the time is between 00:15 utc and 00:45 utc
      if @startup or ( Time.now.utc.hour==00 and Time.now.min >= 15 and Time.now.min < 45)
        @startup=false
        exchange = Array.new
        # Bittrex (https://bittrex.com/api/v1.1/public/getticker?market=btc-egc)
        bittrex = JSON.parse(open("https://bittrex.com/api/v1.1/public/getticker?market=btc-egc").read)
        exchange << {:name => "Bittrex", :last => bittrex["result"]["Last"]}

        # c-cex (https://c-cex.com/t/egc-btc.json)
        ccex = JSON.parse(open("https://c-cex.com/t/egc-btc.json").read)
        exchange << {:name => "C-Cex", :last => ccex["ticker"]["lastprice"]}

        # cryptopia (https://www.cryptopia.co.nz/api/GetMarket/2788/24)
        tradePairId = 2788 # from https://www.cryptopia.co.nz/api/GetMarkets
        hours=24
        cryptopia = JSON.parse(open("https://www.cryptopia.co.nz/api/GetMarket/#{tradePairId}/#{hours}").read)
        exchange << {:name => "Cryptopia", :last => cryptopia["Data"]["LastPrice"]}

        # yobit (https://yobit.net/api/2/egc_btc/ticker)
        yobit = JSON.parse(open("https://yobit.net/api/2/egc_btc/ticker").read)
        exchange << {:name => "Yobit", :last => yobit["ticker"]["last"]}

        @bot.handlers.dispatch(:exchange_update, nil, exchange)
      end
      sleep 1800 # 30 minutes
    end
  end
end

