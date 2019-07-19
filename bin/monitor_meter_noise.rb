#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "lib")

SAMPLE_PERIOD = 60

require 'monitor_meter/config'

begin
  @config = MonitorMeter::Config.new

  noise_file = @config['noise_file']
  unless noise_file
    puts "noise file not set in config"
    exit 1
  end

  data = `/usr/bin/arecord -d #{SAMPLE_PERIOD} -vvv -N /dev/null 2>/dev/null`
  peaks = data.scan(/(\d+)%$/).flatten.collect { |i| i.to_i }
  if peaks.count > 0
    average = peaks.inject(:+).to_f / peaks.count
    File.open(noise_file, "w") { |f| f.puts(average) }
    puts "average noise peak: #{average}"
  else
    puts "unable to parse arecord output"
  end

end
