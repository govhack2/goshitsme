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

SUBURBS = {}

puts xlsx_files.first

#------------------------------------------------------------------------------#

csv_files.each do |file|
  next unless match =  /^.*_(B[0-9]+[AB]*)_AUST_([^_]+)/.match(file)
  type, region = match[1..2]
  region = 'AUST' if region == 'long.csv'
  next unless region == 'SSC'
  rows = CSV.parse(File.read(file))
  headings = rows[0]
  rows = rows[1..-1].map { |row| Hash[headings.zip(row)] }
  rows.map! do |row|
    {
      state: STATES.find { |k, v| row['region_id'] =~ /#{k}/ }.last,
      suburb: SUBURBS[row['region_id']],
      gender: {
        male: row['Total_Persons_Males'].to_i,
        female: row['Total_Persons_Females'].to_i
      },
      age: {
        '0-4' => row['Age_groups_0_4_years_Persons'].to_i,
        '5-14' => row['Age_groups_5_14_years_Persons'].to_i,
        '15-19' => row['Age_groups_15_19_years_Persons'].to_i,
        '20-24' => row['Age_groups_20_24_years_Persons'].to_i,
        '25-34' => row['Age_groups_25_34_years_Persons'].to_i,
        '35-44' => row['Age_groups_35_44_years_Persons'].to_i,
        '45-54' => row['Age_groups_45_54_years_Persons'].to_i,
        '55-64' => row['Age_groups_55_64_years_Persons'].to_i,
        '65-74' => row['Age_groups_65_74_years_Persons'].to_i,
        '75-84' => row['Age_groups_75_84_years_Persons'].to_i,
        '85-??' => row['Age_groups_85_years_and_over_Persons'].to_i,
      },
      birthplace: {
        australia: row['Birthplace_Australia_Persons'].to_i,
        elsewhere: row['Birthplace_Elsewhere_Persons'].to_i
      },
      languages: {
        english: row['Language_spoken_at_home_English_only_Persons'].to_i,
        other: row['Language_spoken_at_home_Other_Language_Persons'].to_i
      },
      school: {
        unattended: row['Highest_year_of_school_completed_Did_not_go_to_school_Persons'].to_i,
        year_8: row['Highest_year_of_school_completed_Year_8_or_below_Persons'].to_i,
        year_9: row['Highest_year_of_school_completed_Year_9_or_equivalent_Persons'].to_i,
        year_10: row['Highest_year_of_school_completed_Year_10_or_equivalent_Persons'].to_i,
        year_11: row['Highest_year_of_school_completed_Year_11_or_equivalent_Persons'].to_i,
        year_12: row['Highest_year_of_school_completed_Year_12_or_equivalent_Persons'].to_i
      }
    }
  end
  ap rows[0]
  exit
end

#==============================================================================#
