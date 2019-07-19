#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'bundler'
Bundler.setup
require 'monitor_meter'
require 'timeout'

def read_temperature
  return nil unless @temp.enabled?
  Timeout::timeout(5) do
    @temp.take_measurement
  end
end

def read_noise
  noise_file = @config['noise_file']

  return nil unless noise_file && File.exist?(noise_file)
  age = Time.now.to_i - File.new(noise_file).mtime.to_i
  return nil unless age < @config.status_interval

  noise = File.read(noise_file)
  noise.to_f
end

begin
  @config = MonitorMeter::Config.new
  @db = MonitorMeter::DB.new(@config)
  @led = MonitorMeter::LED.new(@config)
  @temp = MonitorMeter::TemperatureSensor.new(@config)

  puts "led pin: #{@led.pin}"

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
      temp = read_temperature
      noise = read_noise
      @db.add_measurement(@tick, temp, noise, timestamp)
      @tick = 0
      @last_record = timestamp
    end

  end

end
