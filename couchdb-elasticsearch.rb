#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler/setup'

require 'json/ext'
require 'couchrest'
require 'tire'
#require 'yajl/json_gem'
require 'faker'

require 'pry'

class ElasticSearchTest
  attr_accessor :num_items, :num_packs

  TAGS = %w(tag1 tag2 tag3 tag4 tag5 tag6 tag7 tag8 tag9 tag10 tag11)

  def initialize(num_packs, num_items = 25)
    @num_items = num_items
    @num_packs = num_packs
  end

  def random_tags
    len = rand(TAGS.length-6)
    TAGS.shuffle[0..len]
  end

  # Create and insert data into CouchDB. If everything is fine,
  # elasticsearch should be indexing this data too, via the River plugin.
  def setup
    db = CouchRest.database!("http://127.0.0.1:5984/couchdb_test")

     (1..@num_packs).each do |num_pack|
      elems = []
      (1..@num_items).each do |num_item|
        elems << { :name => Faker::Name.name, :tags => random_tags(), :created_at => Time.now() }
      end

      response = db.bulk_save(elems)
      puts response
    end

  end

  # Query elasticsearch.
  def run tags
    s = Tire.search 'couchdb_test'  do
      tags.each do |tag|
         filter :terms, :tags => [tag]
         #query do
         # string "name:*#{tag}*"
         #end
      end
      from "1"
      size "1000"
    end
    s.sort {by :created_at, 'desc'}

    s.results
  end

  def debug_results(items)
    items.each { |item| puts "(#{i[:created_at]}) :" + i[:name] + " " + i[:tags].to_s }
  end

end

# ¡Let's measure!
include Benchmark

[[1,100], [100, 1000], [1000,1000]].each do |packs, items|

  test = ElasticSearchTest.new(packs,items)

  time_for_saving = Benchmark.realtime { test.setup }
  time_for_reading = Benchmark.realtime { @results = test.run(['tag1','tag3','tag2','tag4']) }

  test.debug_results(@results)

  puts "#{packs*items} (#{packs} * #{items}) = #{time_for_saving} + #{time_for_reading} = #{time_for_reading+time_for_saving} (resultados = #{@results.total})"

end
