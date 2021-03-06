#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'bundler/setup'
require 'monitor_meter'
require 'net/http'

API_ADD_STATUS = URI.parse("http://pvoutput.org/service/r2/addstatus.jsp")

def upload_measurement(measurement)
  time = Time.at(measurement.created_at)
  hours = @config.status_interval.to_f / (60 * 60)

  # convert watt-hours to watts
  # I think one 'pulse' is counted as when the led turns off and on,
  # so divide the number of changes by two here.
  net_power = measurement.value / (2.0 * hours)

  headers = {
    'X-Pvoutput-Apikey' => "#{@config['pvoutput_api_key']}",
    'X-Pvoutput-SystemId' => "#{@config['pvoutput_system_id']}"
  }
  params = {
    'd' => time.strftime("%Y%m%d"),
    't' => time.strftime("%H:%M"),
    'v4' => net_power,
    'n' => @config['net_import'] ? "1" : "0"
  }

  params['v5'] = measurement.temperature if measurement.temperature
  params['v7'] = "%.3f" % [measurement.noise] if measurement.noise

  body = URI.encode_www_form(params)
  puts body
  response = @http.post(API_ADD_STATUS.path, body, headers)

  raise response.body unless response.code.to_i == 200
  puts response.body

  response
end

begin
  @config = MonitorMeter::Config.new
  @db = MonitorMeter::DB.new(@config)
  @http = Net::HTTP.new(API_ADD_STATUS.host, API_ADD_STATUS.port)

  list = @db.measurements_for_upload
  uploaded = []

  begin
    # upload measurements
    puts "uploading #{list.length} measurements"
    
    list.each do |measurement|
      upload_measurement(measurement)
      uploaded << measurement
    end

  rescue Exception => e
    puts e
  end

  @db.mark_uploaded(uploaded)
  puts "#{uploaded.length} measurements uploaded"

end
