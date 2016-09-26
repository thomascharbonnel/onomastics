#!/usr/bin/env ruby
# coding: utf-8

require 'json/ext'
require 'ruby-fann'
require 'pp'

class String
  @@not_null_regex = Regexp.new(/[^\x00]/)

  def to_a
    array = Array.new(size, 0)
    start = index(@@not_null_regex)
    start.upto(size-1) do |i|
      array[i] = self[i].ord
    end
    array
  end
end

start_time = Time.now

longest_name_size = 0
# Sets are slow                          h.size is O(1)
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

import_time = Time.now
puts "Data imported in #{import_time - start_time} seconds."

all_citizenships.freeze

# Now, a bit of data conversion.

# A little bit clearer variable names.
blank_output = "\x00" * all_citizenships.size
blank_output.freeze # Can't touch this, hmm hmm hmm hmm, hm hm, hm hm.
blank_input = "\x00" * longest_name_size
blank_input.freeze

# One should note that string operations are fast while arry operations are
# fairly slow. Dupping strings is constant time (memory copy), while .chars
# and .map! on arrays are O(m) for m characters.
# So, here we get O(n * (m0 + m1)), with n training rows, m0 name size and m1
# number of citizenships. Ugh.
# Also, prefer bang methods over their non-bang counterparts, creating new
# objects takes quite some time.

inputs = [] # An array of names, all have the same size, 0 as left padding.
outputs = [] # An array of binary arrays (1 has that country of ctzp, 0 not).
# There's way too much data to use fancy maps and stuff, KISS.
data.each_with_index do |(name, ctzp), index|
  puts "\tIteration ##{index}" if index % 100_000 == 0

  input = blank_input.dup
  input[input.size-name.size..input.size] = name
  inputs << input.to_a

  output = blank_output.dup
  ctzp.each { |c| output[all_citizenships[c]] = "\x01" }
  outputs << output.to_a
end

training_data_time = Time.now
puts "Raw training data generated in #{training_data_time - import_time} " \
     "seconds (Total: #{training_data_time - start_time} seconds)."

# ANN, Let's do this!
# Oh yeah, this ANN is gonna be fed.
train = RubyFann::TrainData.new(:inputs => inputs, :desired_outputs => outputs)
ann = RubyFann::Standard.new(:num_inputs => longest_name_size, :hidden_neurons => [(longest_name_size * 1.3).to_i, (longest_name_size * 0.7).to_i, longest_name_size], :num_outputs => all_citizenships.size)
ann.train_on_data(train, 10_000_000, 20, 0.01)

ann_fed_time = Time.now
puts "Training data fed in #{ann_fed_time - training_data_time} seconds " \
     "(Total: #{ann_fed_time - start_time} seconds)"

