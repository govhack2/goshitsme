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
  description: 'Roll for identity!',
  questions: [
    {
      label: 'State or Territory',
      description: 'Where do you live?',
      count: 0,
      answers: [],
      locations: []
    },
    {
      label: 'Local Government',
      description: 'Which area do you live in within New South Wales?',
      count: 0,
      answers: [],
      locations: []
    },
    {
      label: 'Gender',
      description: 'What is your gender?',
      count: 0,
      answers: [],
      locations: []
    },
    {
      label: 'Age',
      description: 'How old are you?',
      count: 0,
      answers: [],
      locations: []
    },
    {
      label: 'Occupation',
      description: 'What do you do?',
      count: 0,
      answers: [],
      locations: []
    }
  ]
}

files.each do |file|

  drilldown = false
  question = nil
  answer = nil
  if occupation = /earners_(.*)\./.match(file)[1]
    question = 'Occupation'
    answer = occupation.capitalize
    drilldown = true
    location = []
  end
  next unless question && answer

  data = results[:questions].find { |d| d[:label] == question }
  next if data.nil?

  doc = RubyXL::Parser.parse(file)
  rows = doc[0].sheet_data

  meta = {
    name: rows[3][2].value,
    license: 'Creative Commons Attribution 2.5 Australia',
    attribution: 'Based on Australian Bureau of Statistics Data',
    state: nil,
    drilldown: drilldown
  }
  data.merge!(meta)

  headings = [rows[5][0].value] + rows[4][2..9].map(&:value)
  state = nil

  rows[6..-1].each do |row|
    row.map!(&:value)
    row.slice!(1)
    row.map! { |v| v.to_i if Float(v) rescue v.strip unless v.nil? }
    row = Hash[headings.zip(row)]
    count = 0
    year = nil
    row.keys.each do |key|
      next unless row[key].is_a?(Numeric)
      year = key
      count = row[key]
    end
    next unless year
    current = if row['Location'] == config.location.total
      data
    else
      found = false
      config.location.states.each do |name|
        next unless row['Location'] == name
        unless state = data[:locations].find { |d| d[:label] == name }
          state = {
            label: name,
            count: 0,
            answers: [],
            locations: []
          }
          data[:locations] << state
        end
        found = true
      end
      if found
        state
      else
        unless town = state[:locations].find { |d| d[:label] == row['Location'] }
          town = {
            label: row['Location'],
            count: 0,
            answers: []
          }
          state[:locations] << town
        end
        town
      end
    end
    current[:answers] << {
      label: answer,
      count: count
    }
    current[:count] += count
    current[:year] = year
  end

end

#==============================================================================#
