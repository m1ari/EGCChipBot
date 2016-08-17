#!/usr/bin/env ruby
require 'cinch'
require 'pp'

# Taking some ideas from:
# https://github.com/Quintus/cinch-plugins/blob/master/plugins/logging.rb
# https://github.com/Quintus/cinch-plugins/blob/master/plugins/logplus.rb

class Logger
  include Cinch::Plugin

  # Class to be pushed into the bots loggers to capture outgoing messages
  class OutgoingLogger < Cinch::Logger
    def initialize(&callback)
      super(File.open("/dev/null"))
      @callback = callback
    end

    # Logs a message. Calls the callback if the +event+ is
    # an "outgoing" event.
    def log(messages, event = :debug, level = event)
      # "PRIVMSG #ukhasnet-test :Bittrex 0.00018050 | C-Cex 0.00019000 | Cryptopia 0.00030000 | Yobit 0.00017138"
      # TODO could we create a cinch message object to pass back

      if event == :outgoing
        Array(messages).each do |msg|
          if msg =~ /^PRIVMSG (.*?):/
            @callback.call($1.chomp(' '), $', level, false)
          elsif msg =~ /^NOTICE (.*?):/
            @callback.call($1.chomp(' '), $', level, true)
          end
        end
      end
    end
  end

  def initialize(*args)
    super
    @logfile = {}
  end


  listen_to :connect,    :method => :startup
  listen_to :disconnect, :method => :cleanup
  listen_to :channel,    :method => :log_public_message
  listen_to :private,    :method => :log_private_message
  #listen_to :topic,      :method => :log_topic
  #listen_to :join,       :method => :log_join
  #listen_to :leaving,    :method => :log_leaving
  #listen_to :nick,       :method => :log_nick
  #listen_to :mode_change,:method => :log_modechange
  timer 60,              :method => :check_midnight

  def startup(*)
    @logdir           = config[:logdir]           || File.join(File.expand_path(File.dirname($0)), "logs")
    @last_time_check  = Time.now

    @filemutex = Mutex.new

    unless Dir.exists? @logdir
      bot.info "Creating Logdir #{@logdir}"
      Dir.mkdir @logdir
    end

    # TODO for known channels we should open logs here

    bot.loggers.push(OutgoingLogger.new(&method(:log_own_message)))
  end


  def cleanup(*)
    @logfile.each do |k,v|
      close_log(k)
    end
  end

  def check_midnight
    time = Time.now

    if @last_time_check.day != time.day
      @filemutex.synchronize do
        @logfile.each do |k,v|
          close_log(k)

          # If it's a channel re-open the log file
          if bot.channels.include? k
            open_log(k)
          else
            @logfile.delete(k)
          end
        end
      end
      @last_time_check = time
    end
  end

  def close_log(channel)
    bot.info "Closing log for #{channel}"
    @logfile[channel].puts "----- Logfile Closed at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")} -----"
    @logfile[channel].close
    # TODO, set @logfile[channel] to nil - or similar?
  end

  def open_log(chan)
    bot.info "Opening log for #{chan.to_s}"

    filename = Time.now.strftime("%Y-%m-%d") + ".log"
    log_dir = File.join(@logdir,chan.to_s)

    unless Dir.exists? log_dir
      bot.info "Creating Logdir #{log_dir}"
      Dir.mkdir log_dir
    end

    @logfile[chan.to_s]=File.open(File.join(log_dir,filename), 'a')
    @logfile[chan.to_s].sync = true
    @logfile[chan.to_s].puts "----- Logfile Opened at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")} -----"

    # If it's a channel log the topic
    if bot.channels.include? chan
      @logfile[chan.to_s].puts "--- Topic: #{bot.channels[bot.channels.index(chan)].topic}"
      users=[]
      bot.channels[bot.channels.index(chan)].users.each do |k,v|
        users << nick_to_s(k,v)
      end
      @logfile[chan.to_s].puts "--- Users: #{users.join(",")}"
      #@logfile[chan.to_s].puts "--- Users: #{chan.users}"
    end

  end

  def nick_to_s(user,flags)
    if flags.include? 'o'
      return '@' + user.nick
    else
      return ' ' + user.nick
    end
  end

  def log_message(channel, time, nick, msg)
    open_log(channel) unless @logfile.has_key? channel.to_s
    # TODO if message starts with !h don't log it

    @logfile[channel.to_s].puts(sprintf("%{time} <%{nick}> %{msg}",
                                    :time => time.strftime("%H:%M"),
                                    :nick => nick,
                                    :msg => msg))
                                    
    # TODO db logging
# Irssi log format
#01:24 -!- haplo37__ [~haplo37@107-190-44-23.cpe.teksavvy.com] has joined #freenode
#01:25 <+mniip> hah
#01:25 <+mniip> of all people
#01:26 -!- Jelmer_ [~Jelmer@ip54534744.speed.planet.nl] has quit [Quit: Leaving]
#01:27 -!- mode/#freenode [+vvvv GameGear Genesis15 Guest58060 PalTale] by eir
#15:17  * Armand smirks

  end

  def log_public_message(msg)
    log_message(msg.channel, msg.time,  msg.user, msg.message)
  end

  def log_private_message(msg)
    if msg.user.nil?
      bot.info "Not logging \"#{msg.message}\" as no user set"
    else
      log_message(msg.user, msg.time, msg.user, msg.message)
    end
  end

  def log_own_message(dest, text, level, is_notice)
    log_message(dest, Time.now, bot.nick, text)
  end

  #match /censor (.*)/, method: :censor
  # !censor entire line
  # !censor %partial line%
  def censor(m)
  end

end
