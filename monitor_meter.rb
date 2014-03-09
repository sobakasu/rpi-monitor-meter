#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'monitor_meter/db'
require 'monitor_meter/config'
require 'monitor_meter/led'

begin
  @config = MonitorMeter::Config.new
  @db = MonitorMeter::DB.new(@config)

  @led = MonitorMeter::LED.new
  @led.threshold_min = @config['led_threshold_min']
  @led.threshold_max = @config['led_threshold_max']

  @tick = 0
  @last_record = @db.last_record_time

  puts "status interval: #{@config.status_interval} seconds"

  while true do
    if @led.changed?
      @tick += 1
      puts "tick: #{@tick}"
    end

    now = Time.now
    hour_seconds = now.sec + now.min * 60
    timestamp = now.to_i

    if hour_seconds % @config.status_interval == 0 && @last_record != timestamp
      puts "writing measurement"
      @db.add_measurement(@tick, timestamp)
      @tick = 0
      @last_record = timestamp
    end

  end

end
