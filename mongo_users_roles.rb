#!/opt/chef/embedded/bin/ruby
#
# This script extracts users and roles from a
# json mongo dump and generates a CSV output
#
# Wed May 29 12:01:44 CEST 2019 - hanr
#
require 'rubygems'
require 'json'

data = JSON.parse(File.read(ARGV[0]))

data.each do |id|
  id.each do |k,v|
    print "#{v};" if k == "user"
    if k == "customData"
      v.each do |customdata|
        print customdata[1]
      end
    end
    print "#{v};" if k == "role"
    if k == "roles" || k == "inheritedRoles"
      v.each do |role|
        role.each do |kk,vv|
         print ";#{vv}" if kk == "role"
         print ";#{vv}" if kk == "db"
        end
      end
    end
  end
  puts
end

