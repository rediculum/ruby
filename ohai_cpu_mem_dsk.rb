#!/usr/bin/ruby
#
# This script extracts information from OHAI regarding
# CPU, Memory and Diskspace usage
#
# Fri May 31 14:58:49 CEST 2019 - hanr
#
require 'rubygems'
require 'json'

output = `knife search node 'role:*'  -a filesystem -a platform -a platform_version -F json`
obj = JSON.parse(output)

obj['rows'].each do |server|
  server.each do |key,value|
    json_out = {}

    puts "### #{key} ###"
    json_out[key] = {}
    
    # Memory
    memory = value['memory']['total'].to_i / 1000000
    puts "Memory: #{memory}GB"
    json_out[key]['Memory'] = memory

    # CPU
    cpucount = value['cpu']['total'].to_i
    puts "CPU: #{cpucount}"
    json_out[key]['CPU'] = cpucount

    # Diskspace
    diskspace = 0
    value['block_device'].each do |blockdevice,v|
      if blockdevice =~ /^sd/
        size = v['size'].to_i / 1048576 / 2
        diskspace += size
        #puts "#{blockdevice}: #{size}GB"
      end
    end
    puts "Diskspace: #{diskspace}GB"
    json_out[key]['Disk'] = diskspace

    puts "\n\nJSON output:"
    puts JSON.pretty_generate(json_out)
  end
end
