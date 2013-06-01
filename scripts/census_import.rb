#!/usr/bin/env ruby

#==============================================================================#

require 'rubygems'
require 'bundler'

Bundler.require(:development, :import)

require 'logger'
require 'fileutils'
require 'csv'

FileUtils::mkdir_p('log')
log = Logger.new('log/import.log')

log.info 'STARTED'
at_exit { log.info 'STOPPED' }

config = Hashie::Mash.new(Oj.load(File.read('config/census_import.json')))

config.path = File.expand_path(config.path)
xlsx_files = Dir["#{config.path}/**/*.xlsx"]
csv_files = Dir["#{config.path}/**/*.csv"]

#------------------------------------------------------------------------------#

STATES = {
  'SSC1' => 'NSW',
  'SSC2' => 'VIC',
  'SSC3' => 'QLD',
  'SSC4' => 'SA',
  'SSC5' => 'WA',
  'SSC6' => 'TAS',
  'SSC7' => 'NT',
  'SSC8' => 'ACT',
  'SSC9' => 'Other'
}

file = File.join(config.path, '2011Census_geog_desc_1st_and_2nd_release.csv')
rows = CSV.parse(File.read(file))
headings = rows[0]
rows = rows[1..-1].map { |row| Hash[headings.zip(row)] }
rows.select! { |row| row['Code'] =~ /^SSC/ }
SUBURBS = Hash[rows.map do |row|
  [row['Code'], { name: row['Label'], area: row['Area sqkm'] }]
end]

#------------------------------------------------------------------------------#

def _add_entry(row, entry, name, pattern, num = 2)
  row.each do |header, count|
    next if header =~ /Not_stated/i
    next unless match = pattern.match(header)
    next unless match.length == num
    dimension = match[num-1]
    dimension = 'None' if dimension.length == 0
    next if dimension =~ /Total/
    entry[name] ||= {}
    entry[name][dimension] ||= 0
    entry[name][dimension] += count.to_i
  end
end

#------------------------------------------------------------------------------#

data = {}
csv_files.each do |file|
  next unless match =  /^.*_(B[0-9]+[AB]*)_AUST_([^_]+)/.match(file)
  type, region = match[1..2]
  region = 'AUST' if region == 'long.csv'
  #next unless region == 'SSC'
  next unless region == 'AUST'
  rows = CSV.parse(File.read(file))
  headings = rows[0]
  rows = rows[1..-1].map { |row| Hash[headings.zip(row)] }
  STDERR.puts file
  rows.each do |row|
    state = STATES.find { |k, v| row['region_id'] =~ /#{k}/ }.last rescue nil
    suburb = SUBURBS[row['region_id']][:name] rescue nil
    data[state] ||= {}
    data[state][suburb] ||= {}
    entry = data[state][suburb]
    entry[:state] ||= state
    entry[:suburb] ||= suburb
    if type =~ /B01/
      _add_entry(row, entry, :gender, /^Total_Persons_([^P].*)/)
      _add_entry(row, entry, :age, /^Age_groups_(.*)_Persons/)
      _add_entry(row, entry, :school_completed, /^Highest_year_of_school_completed_(.*)_Persons/)
      row.each do |k, v|
        next if k =~ /(Total|Persons|Males|Females)/
        next if k =~ /Not_stated/
        next unless match = /^(.*)_Occupation_(.*)/.match(k)
        next unless match.length == 3
        industry, occupation = match[1..2]
        entry[:industry] ||= {}
        entry[:industry][industry] ||= 0
        entry[:industry][industry] += v.to_i
        entry[:occupation] ||= {}
        entry[:occupation][occupation] ||= 0
        entry[:occupation][occupation] += v.to_i
      end
    end
    if type =~ /B24/
      _add_entry(row, entry, :number_of_children, /^Total_Number_of_children_ever_born_(.*)/)
    end
    if type =~ /B29/
      _add_entry(row, entry, :vehicles_per_house, /^Number_of_motor_vehicles_per_dwelling_(.*)_Dwellings/)
    end
    if type =~ /B28/
      _add_entry(row, entry, :weekly_household_income, /^([0-9]+.*)_Total/)
    end
    if type =~ /B33/
      _add_entry(row, entry, :monthly_mortgage_repayment, /^([0-9]+.*)_Total/)
    end
    if type =~ /B34/
      _add_entry(row, entry, :weekly_rent, /^([0-9]+.*)_Total/)
    end
    if type =~ /B35/
      _add_entry(row, entry, :internet_type, /connection_(.*?)[_]*Total/)
    end
    if type =~ /B46/
      _add_entry(row, entry, :travel_to_work, /(.*?)_Persons/)
    end
    if type =~ /B14/
      _add_entry(row, entry, :religion, /(.*?)_Persons/)
    end
    if type =~ /B09/
      _add_entry(row, entry, :country_of_birth, /(.*?)_Persons/)
    end
    if type =~ /B13/
      _add_entry(row, entry, :languages_spoken, /Speaks_(other_language_)*(.*?)_Persons/, 3)
    end
    if type =~ /B05/
      _add_entry(row, entry, :marital_status, /Persons_Total_(.*)/)
    end
    if type =~ /B17/
      _add_entry(row, entry, :weekly_personal_income, /Persons_(.*)_Total/)
    end
    if type =~ /B41/
      _add_entry(row, entry, :qualifications, /Persons_(.*)_Total/)
    end
  end
end

File.open('data/australia.json', 'wb') do |file|
  file.write(MultiJson.dump(data, pretty: true))
end

#==============================================================================#
