#!/usr/bin/ruby
#
# This script extracts currently mounted file systems via OHAI
# from a node and regenerates the fstab as output
# Additionally it creates a JSON output which can be used
# as a data bag item in CHEF
#
# Fri May 31 15:04:52 CEST 2019 - hanr

require 'rubygems'
require 'json'

#output = `knife search node 'role:*'  -a filesystem -a platform -a platform_version -F json`
output = `knife search node 'fqdn:sa1600222.gch.generali.ch' -a filesystem -a platform -a platform_version -F json`
obj = JSON.parse(output)

servers = obj['rows']

excl_fs_rhel6 = %w(rootfs none devtmpfs hugetlbfs sunrpc binfmt_misc cgroup pipefs mqueue hugepages selinuxfs securityfs pstore efivarfs configfs systemd-1 debugfs)
excl_fs_rhel7 = %w(devpts sysfs proc)
excl_mount_points = %w(/sys/fs/cgroup /run /proc/bus/usb)
excl_mount_opts = %w(rw relatime seclabel attr2 inode64 noquota)

exclude = ['localhost']

servers.each do |server|
  server.each do |key,value|
    next if (key == nil)
    if (exclude.include?(key) || value['filesystem'] == nil) then
      STDERR.print "Excluding:" + key
      if (value['filesystem'] == nil) then
        STDERR.print "It was because no filesystem data. (probably aix?)"
      end
      puts
      next
    end

    json_out = {}

    puts "### #{key} (#{value['platform']} #{value['platform_version']}) ###"
    json_out['id'] = key
    json_out['os'] = [value['platform'], "_", value['platform_version']].join
    mountpoints = value['filesystem']['by_device']

    value['platform_version'].to_i == 7 ? excl_fs = excl_fs_rhel6 + excl_fs_rhel7 : excl_fs = excl_fs_rhel6

    if (mountpoints != nil) then
      mountpoints.each do |device_key, mp_v|
        next if excl_mount_points.any? { |m| mp_v['mounts'].include?(m) } or excl_fs.include? device_key or mp_v['mounts'].empty? or ( mp_v['fs_type'] =~ /^nfs/ and !mp_v['kb_size'] )

        device_key = "UUID=#{mp_v['uuid']}" if device_key =~ /\/dev\/sda/

        json_out[device_key] = {}

        json_out[device_key]['mount_point'] = mp_v['mounts'][0]
        json_out[device_key]['fs_type'] = mp_v['fs_type']

        mp_v['mount_options'] = mp_v['mount_options'] - excl_mount_opts
        mp_v['fs_type'] =~ /^nfs|^proc$|^sysfs$|^tmpfs$/ || mp_v['mount_options'].empty? ? ( json_out[device_key]['mount_opts'] = 'defaults' ) : ( json_out[device_key]['mount_opts'] = mp_v['mount_options'].join(',')  )
        mp_v['mounts'][0] =~ (/\/boot|^\/$/) ? ( json_out[device_key]['fsck'] = "1"; json_out[device_key]['dump'] = "2" ) : ( json_out[device_key]['fsck'] = "0"; json_out[device_key]['dump'] = "0" )
      end
    end
    puts "JSON output:"
    puts JSON.pretty_generate(json_out)
    File.write([key,'.json'].join, JSON.pretty_generate(json_out))

    puts "\nRegenerate /etc/fstab:"
    json_out.each do |device_key, device_values|
      next if device_key.match(/^id$|^os$/)
      print "#{device_key}\t"
      device_values.each do |k,v|
        print "#{v}\t"
      end
      print "\n"
    end
  end
end

