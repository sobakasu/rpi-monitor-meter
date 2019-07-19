#!/usr/bin/env ruby
#
### BEGIN INIT INFO
# Provides:       monitor_meter
# Required-Start: $local_fs
# Default-Start:  2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start Monitor Meter
# Description: loads monitor meter
### END INIT INFO

file = __FILE__
file = File.readlink(file) if File.symlink?(file)
Dir.chdir(File.join(File.dirname(file), ".."))
path = File.join(File.dirname(file), 'monitor_meter.rb')

require 'rubygems'
require 'bundler/setup'
require 'daemons'

options = {
  backtrace: true,
  log_output: true,
  monitor: true,
  dir_mode: :system
}
Daemons.run(path, options)
