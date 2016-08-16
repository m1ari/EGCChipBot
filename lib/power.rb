#!/usr/bin/env ruby
require 'cinch'
require_relative 'axp209'

class Power
  include Cinch::Plugin

  def initialize(*args)
    super
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

end

