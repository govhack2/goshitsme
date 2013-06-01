#!/usr/bin/env ruby

#==============================================================================#

require 'rubygems'
require 'bundler'

Bundler.require(:development, :import)

require 'logger'
require 'fileutils'

FileUtils::mkdir_p('log')
log = Logger.new('log/import.log')

log.info "STARTED"
at_exit { log.info "STOPPED" }

config = Hashie::Mash.new(Oj.load(File.read('config/import.json')))

config.path = File.expand_path(config.path)
files = Dir["#{config.path}/**/*.xlsx"]

#------------------------------------------------------------------------------#

data = {
  location: {},
  population: {},
  age: {},
  gender: {},
  occupation: {}
}

files.each do |file|
  puts file
  doc = RubyXL::Parser.parse(file)
  rows = doc[0].sheet_data
  name = rows[3][1].value
  headings = [rows[5][0].value] + rows[4][2..9].map(&:value)
  rows[6..-1].each do |row|
    row.map!(&:value)
    row.slice!(1)
    row.map! { |v| v.to_i if Float(v) rescue v.strip unless v.nil? }
    ap row
  end
end

#==============================================================================#
