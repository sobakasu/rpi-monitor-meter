#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'monitor_meter/config'
require 'monitor_meter/led'
require 'monitor_meter/temperature_sensor'

begin
  @config = MonitorMeter::Config.new
  
  @led = MonitorMeter::LED.new(@config)
  @led.threshold_max = 100
  
  @temp = MonitorMeter::TemperatureSensor.new(@config)

  puts "measurement: #{@led.take_measurement}"
  puts "temperature: #{@temp.take_measurement}"

end
