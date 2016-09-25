#!/usr/bin/env ruby
# coding: utf-8

require 'json/ext'
require 'ruby-fann'

longest_name_size = 0
# Sets are slow
all_citizenships = Hash.new { |h, e| h[e] = h.size } # Jedi mind trick
data = {}

# First, let's import the data.
# We can store all the content in memory.
# This could be improved by putting the number of citizenships
# in the training file's header. We could then feed the NN directly.
ARGF.each do |line| # O(n), n lines in the training set.
  name, ctzp = line.split ';'
  ctzp = JSON.parse(ctzp)

  longest_name_size = name.size if name.size > longest_name_size
  data[name] = ctzp
  ctzp.each { |f| all_citizenships[f] }
end
