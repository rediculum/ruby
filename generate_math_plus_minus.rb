#!/usr/bin/ruby
#
# This script is for practicing math (+ and -)
# Define the max range number and if a PDF
# should be generated or interactive asking
#
# Sun Apr 14 17:41:50 CEST 2019 - hanr
#
require 'prawn'

max_number = 20
write_pdf = false
interactive = true

system 'clear'

Prawn::Document.generate(File.basename(__FILE__) + ".pdf") do
  10.times do
    first_plus = rand(1..max_number / 2)
    second_plus = rand(1..max_number / 2)
    first_minus = rand(1..max_number)
    second_minus = rand(1..max_number)
    operator = rand(0..1) # 0 = plus, 1 = minus
    
    if operator == 0
      result = first_plus + second_plus
      if write_pdf
        text "#{first_plus} + #{second_plus} = ___", size: 30
      elsif interactive
        print "#{first_plus} + #{second_plus} = " 
        input = gets.chomp
        input.to_i == result ? ( puts "OK!" ) : ( puts "No." )
      else
        puts "#{first_plus} + #{second_plus} = ___" 
      end
    elsif operator == 1
      first_minus,second_minus = second_minus,first_minus if first_minus < second_minus
      result = first_minus - second_minus
      if write_pdf
        text "#{first_minus} - #{second_minus} = ___", size: 30
      elsif interactive
        print "#{first_minus} - #{second_minus} = " 
        input = gets.chomp
        input.to_i == result ? ( puts "OK!" ) : ( puts "No." )
      else
        puts "#{first_minus} - #{second_minus} = ___" 
      end
    end
    text " ", size: 30 if write_pdf
  end
end
