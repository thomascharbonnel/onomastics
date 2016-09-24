#!/usr/bin/env ruby
# coding: utf-8

require 'set'
require 'json/ext'

ARGF.each_line do |line|
  next if line =~ /^\[.*$/
  json = JSON.parse(line)

  begin
    name = json['labels']['en']['value']

    export_line = "#{name};"
    export_line += json['claims']['P27'].map do |p|
      c = p['mainsnak']['datavalue']['value']['id']

      # I could probably find something sexier.
      # I COULD.
      raise NoMethodError unless c
      c
    end.to_s

    puts export_line
  rescue NoMethodError
    next
  end
end
