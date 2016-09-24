#!/usr/bin/env ruby
# coding: utf-8

require 'set'
require 'json/ext'

#citizenships = Set.new
#export = File.new('training_set.txt', 'w')
#max_name_length = 0

ARGF.each_line do |line|
  next if line =~ /^\[.*$/
  json = JSON.parse(line)

  begin
    name = json['labels']['en']['value']
#    max_name_length = name.length if name.length > max_name_length

    export_line = "#{name};"
    export_line += json['claims']['P27'].map do |p|
      c = p['mainsnak']['datavalue']['value']['id']

      raise NoMethodError unless c
#      citizenships << c
      c
    end.to_s

    puts export_line
  rescue NoMethodError
    next
  end
end

#export_citizenships = File.new('citizenships', 'w')
#export_citizenships.puts citizenships.to_a

#puts "Max full name length: #{max_name_length}."
