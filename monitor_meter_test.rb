#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'monitor_meter/config'
require 'monitor_meter/led'

begin
  @config = MonitorMeter::Config.new
  @led = MonitorMeter::LED.new(@config)
  @led.threshold_max = 100

  while true do
    puts "measurement: #{@led.take_measurement}"
  end

end
