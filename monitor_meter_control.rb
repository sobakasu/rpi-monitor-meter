#!/usr/bin/env ruby

require 'rubygems'
require 'daemons'

file = __FILE__
file = File.readlink(file) if File.symlink?(file)
path = File.join(File.dirname(file), 'monitor_meter.rb')

options = {
  backtrace: true,
  log_output: true,
  monitor: true,
  dir_mode: :system
}
Daemons.run(path, options)
