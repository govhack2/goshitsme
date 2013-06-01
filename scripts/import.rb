#!/usr/bin/env ruby

#==============================================================================#

require 'rubygems'
require 'bundler'

Bundler.require(:development, :import)

require 'logger'
require 'fileutils'

FileUtils::mkdir_p('log')
log = Logger.new('log/import.log')

log.info 'STARTED'
at_exit { log.info 'STOPPED' }

config = Hashie::Mash.new(Oj.load(File.read('config/import.json')))

config.path = File.expand_path(config.path)
files = Dir["#{config.path}/**/*.xlsx"]

#------------------------------------------------------------------------------#

results = {
  title: 'GoShitMe',
  desription: 'Roll for identity!',
  dimensions: [
    {
      label: 'Location',
      description: 'Where do you live?',
      count: 0,
      options: [],
      dimensions: []
    },
    {
      label: 'Gender',
      description: 'What is your gender?',
      count: 0,
      options: [],
      dimensions: []
    },
    {
      label: 'Age',
      description: 'How old are you?',
      count: 0,
      options: [],
      dimensions: []
    },
    {
      label: 'Occupation',
      description: 'What do you do?',
      count: 0,
      options: [],
      dimensions: []
    }
  ]
}

config.location.states.each do |state|
  results[:dimensions].first[:options] << {
    label: state,
    count: 0,
    options: [],
    dimensions: []
  }
end

files.each do |file|

  if occupation = /earners_(.*)\./.match(file)[1]
    dimension = 'Occupation'
    option = occupation.capitalize
    location = []
  end
  next unless dimension

  data = results[:dimensions].find { |d| d[:label] == dimension }
  next if data.nil?

  doc = RubyXL::Parser.parse(file)
  rows = doc[0].sheet_data

  meta = {
    name: rows[3][2].value,
    license: 'Creative Commons Attribution 2.5 Australia',
    attribution: 'Based on Australian Bureau of Statistics Data'
  }
  data.merge!(meta)

  headings = [rows[5][0].value] + rows[4][2..9].map(&:value)

  ap data
  exit

  rows[6..-1].each do |row|
    row.map!(&:value)
    row.slice!(1)
    row.map! { |v| v.to_i if Float(v) rescue v.strip unless v.nil? }
  end

end

#ap data

#==============================================================================#
