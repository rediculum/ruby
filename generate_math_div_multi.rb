#!/usr/bin/ruby
#
# This script is for practicing math (* and /)
# Define the max range number and if a PDF
# should be generated or interactive asking
#
# Sun Apr 14 17:30:37 CEST 2019 - hanr
#
require 'prawn'

max_number = 10
write_pdf = false
interactive = true

system 'clear'

Prawn::Document.generate(File.basename(__FILE__) + ".pdf") do
  10.times do
    first = rand(1..max_number)
    second = rand(1..max_number)
    result = first * second
    operator = rand(0..1) # 0 = divison, 1 = multiplication

    if operator == 0
      if write_pdf
        text ["#{result} ","\xF7".encode("UTF-8", "Windows-1252")," #{first} = ___"].join, size: 30
      elsif interactive
        print ["#{result} ","\xF7".encode("UTF-8", "Windows-1252")," #{first} = "].join
        input = gets.chomp
        input.to_i == second ? ( puts "Yes!" ) : ( puts "No." )
      else
        puts ["#{result} ","\xF7".encode("UTF-8", "Windows-1252")," #{first} = ___"].join
      end
    elsif operator == 1  
      if write_pdf
        text "#{first} x #{second} = ___", size: 30
      elsif interactive
        print "#{first} x #{second} = "
        input = gets.chomp
        input.to_i == result ? ( puts "Yes!" ) : ( puts "No." )
      else 
        puts "#{first} x #{second} = ___"
      end
    end
    text " ", size: 30 if write_pdf
  end
end
