#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'bundler'
Bundler.setup
require 'monitor_meter'

begin
  @config = MonitorMeter::Config.new
  
  @led = MonitorMeter::LED.new(@config)
  @led.threshold_max = 100
  
  @temp = MonitorMeter::TemperatureSensor.new(@config)

  puts "measurement: #{@led.take_measurement}"
  puts "temperature: #{@temp.take_measurement}"

  exit 0

  ##############################  
  pin_number = @config['led_gpio_pin'].to_i
  puts "pin number: #{pin_number}"
  RPi::GPIO.setup pin_number, as: :output
  RPi::GPIO.set_low pin_number
  #sleep 0.1

  RPi::GPIO.setup pin_number, as: :input
  puts RPi::GPIO.high? pin_number

  time1 = DateTime.now
  sleep 5
  RPi::GPIO.high? pin_number

end


# return time difference in milliseconds
def timediff(time1, time2)
  time2.strftime('%Q').to_i - time1.strftime('%Q').to_i
end

