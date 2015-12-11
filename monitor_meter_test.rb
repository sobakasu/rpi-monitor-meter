#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'monitor_meter/config'
require 'monitor_meter/led'
require 'monitor_meter/temperature_sensor'
require 'pi_piper'

include PiPiper

begin
  @config = MonitorMeter::Config.new
  
  @led = MonitorMeter::LED.new(@config)
  @led.threshold_max = 100
  
  @temp = MonitorMeter::TemperatureSensor.new(@config)

  puts "measurement: #{@led.take_measurement}"
  puts "temperature: #{@temp.take_measurement}"
  
  pin_number = @config['led_gpio_pin'].to_i
  puts "pin number: #{pin_number}"
  pin = PiPiper::Pin.new(pin: pin_number, direction: :out)
  pin.off
  #sleep 0.1

  pin.read
  puts pin.value

  time1 = DateTime.now

  pin = PiPiper::Pin.new(pin: pin_number, direction: :in, trigger: :rising)

      pin.wait_for_change
      puts "pin changed"
      time2 = DateTime.now  

  puts "time for change:"
  puts timediff(time1, time2)
  
  if timediff(time1, time2) < 20
    # led is on
    # wait for pin to fall
    pin = PiPiper::Pin.new(pin: pin_number, direction: :in, trigger: :falling)
    pin.wait_for_change
    puts "pin off -> on"
  else
    # led is off
    puts "pin on -> off"
  end

end


# return time difference in milliseconds
def timediff(time1, time2)
  time2.strftime('%Q').to_i - time1.strftime('%Q').to_i
end

