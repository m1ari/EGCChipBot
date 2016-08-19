#!/usr/bin/env ruby
require 'cinch'
require_relative 'axp209'

class Power
  include Cinch::Plugin

  def initialize(*args)
    super
    @axp209 = I2C::Drivers::AXP209.new(bot, '/dev/i2c-0')
  end

  set :prefix, /!power /

  match "status", method: :status
  def status(m)
    # TODO Get battery status
    m.reply "Running on Battery maybe"
  end

  timer 300, method: :check_power
  def check_power
    # TODO Check power status and alert if running on battery / low voltage
  end

  match /led (on|off|toggle)/, method: :led
  def led(m, status)
    bot.info "Setting LED to #{status}"
    case status
      when 'on'
        @axp209.led_state=1
      when 'off'
        @axp209.led_state=0
      when 'toggle'
        # Get state & set to opposite
      else
        m.reply "Unknown state, set one of: on, off, toggle"
    end
  end

end

