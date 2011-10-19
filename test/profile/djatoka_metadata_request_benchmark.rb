#!/usr/bin/env ruby
require 'rubygems'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib"))
require 'helpers/cacheable'
require 'models/djatoka_metadata'

module ImageService
end

ImageService::DJATOKA_URL = 'http://isis-dev.stanford.edu/adore-djatoka/resolver'
LyberCore::Log.set_logfile($stdout)

require 'benchmark'
Benchmark.bmbm do |x|
      x.report("DjataokaMetadata: memcached") { DjatokaMetadata.find("/stacks/bb/110/sm/8219/bb110sm8219_00_0001.jp2") }
      x.report("DjataokaMetadata: no cache")  { DjatokaMetadata.old_find("/stacks/bb/110/sm/8219/bb110sm8219_00_0001.jp2") }
end

