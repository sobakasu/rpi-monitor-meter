#!/usr/bin/env ruby

require 'rubygems'
require 'daemons'

path = File.join(File.dirname(__FILE__), 'monitor_meter.rb')
Daemons.run(path)
