#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'bundler'
Bundler.setup
require 'monitor_meter'

@config = MonitorMeter::Config.new
@led = MonitorMeter::LED.new(@config)

puts "led: #{@led.pin}"
