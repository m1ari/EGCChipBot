#!/usr/bin/env ruby
# Driver for the AXP209 Power System Management IC
# this IC is used on the C.H.I.P. small board computer
#
# Documentation can be found at
# http://linux-sunxi.org/AXP209
# http://www.chip-community.org/index.php/AXP209
# https://linux-sunxi.org/images/8/89/AXP209_Datasheet_v1.0en.pdf
# https://github.com/NextThingCo/CHIP-Hardware/blob/master/CHIP%5Bv1_0%5D/CHIPv1_0-BOM-Datasheets/AXP209_Datasheet_v1.0en.pdf

# Copyright (c) 2016 Mike Axford <m1ari@m1ari.co.uk>

# TODO We seem to have issues as there's a driver loaded
# We might be able to force i2c by using the _FORCE value
#I2C_SLAVE 0x0703
#I2C_SLAVE_FORCE 0x0706
#@device::I2C_SLAVE = 0x0706  # Set the value to I2C_SLAVE_FORCE as the driver is loaded

require 'i2c/i2c'

module I2C
  module Drivers
    class AXP209
      # Datasheet says 0x69(R)/0x68(W), but that includes the R/W bit at LSB
      # Shifted these become 0x34 and seperate R/W bit
      def initialize(bot, device, address = 0x34)
        @bot = bot
        if device.kind_of?(String)
          @device = ::I2C.create(device)
        else
          [ :read, :write ].each do |m|
            raise IncompatibleDeviceException, 
            "Missing #{m} method in device object." unless device.respond_to?(m)
          end
          @device = device
        end
        @address = address
      end

      def has_battery?
      end

      def battery_volts
      end

      def led_state?
        @bot.info "Query LED state"
        #i2cget -f -y 0 0x34 0x93
      end
      def led_state=(v)
        @bot.info "Set LED state to #{v}"
        #i2cset -f -y 0 0x34 0x93 $1
        @device.write(@address,0x93,v)
      end

    end
  end
end

__END__
# Set state of LED
i2cset -f -y 0 0x34 0x93 $1

# Get state of LED
i2cget -f -y 0 0x34 0x93

#read Power status register @00h
i2cget -y -f 0 0x34 0x00

