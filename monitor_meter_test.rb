#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'monitor_meter/led'

begin
  @led = MonitorMeter::LED.new

  while true do
    puts "measurement: #{@led.take_measurement}"
  end

end
