#!/usr/bin/env ruby

# add another column: prefer not to say

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
  '1' => 'NSW',
  '2' => 'VIC',
  '3' => 'QLD',
  '4' => 'SA',
  '5' => 'WA',
  '6' => 'TAS',
  '7' => 'NT',
  '8' => 'ACT',
  '9' => 'Other'
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
    next if dimension =~ /inadequate/
    entry[name] ||= {}
    entry[name][dimension] ||= 0
    entry[name][dimension] += count.to_i
  end
end

#------------------------------------------------------------------------------#

data = {}
csv_files.each do |file|
  next unless match =  /^.*_(B[0-9]+[ABCD]*)_AUST_([^_]+)/.match(file)
  type, region = match[1..2]
  region = 'AUST' if region == 'long.csv'
  #next unless region == 'SSC'
  next unless region == 'AUST' || region == 'STE'
  rows = CSV.parse(File.read(file))
  headings = rows[0]
  rows = rows[1..-1].map { |row| Hash[headings.zip(row)] }
  STDERR.puts file
  rows.each do |row|
    state = STATES.find { |k, v| row['region_id'] =~ /SSC#{k}/ }.last rescue nil
    state ||= STATES.find { |k, v| row['region_id'] =~ /#{k}/ }.last rescue nil
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
    end
    if type =~ /B40/
      _add_entry(row, entry, :level_of_education, /Persons_(.*)_Total/)
    end
    if type =~ /B43/
      _add_entry(row, entry, :industry_of_employment, /Persons_(.*)_Total/)
    end
    if type =~ /B45/
      _add_entry(row, entry, :occupation, /Total_Occupation_(.*)/)
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

questions = {
  title: "GoShitMe",
  description: "Roll for identity!",
  license: "Creative Commons Attribution 2.5 Australia",
  attribution: "Based on Australian Bureau of Statistics Data",
  year: "2011",
  questions: [
    {
      label: 'State / Territory',
      description: 'Where do you live?',
      count: 0,
      answers: [
        {
          label: 'NSW',
          count: 6917658
        },
        {
          label: 'VIC',
          count: 5354042
        },
        {
          label: 'QLD',
          count: 4332739
        },
        {
          label: 'SA',
          count: 1596572
        },
        {
          label: 'WA',
          count: 2239170
        },
        {
          label: 'TAS',
          count: 495354
        },
        {
          label: 'NT',
          count: 211945
        },
        {
          label: 'ACT',
          count: 357222
        }
      ]
    },
    {
      :code => :gender,
      label: "Gender",
      description: "Which gender are you?",
      count: 0,
      answers: []
    },
    {
      :code => :age,
      label: "Age",
      description: "How old are you?",
      count: 0,
      answers: []
    },
    {
      :code => :marital_status,
      label: "Marital Status",
      description: "What is your marital status?",
      count: 0,
      answers: []
    },
    {
      :code => :country_of_birth,
      label: "Country of Birth",
      description: "Where were you born?",
      count: 0,
      answers: []
    },
    {
      :code => :languages_spoken,
      label: "Languages Spoken",
      description: "Which language are you most proficient in?",
      count: 0,
      answers: []
    },
    {
      :code => :number_of_children,
      label: "Number of Children",
      description: "How many kids have you had?",
      count: 0,
      answers: []
    },
    {
      :code => :vehicles_per_house,
      label: "Number of Cars",
      description: "How many cars do you have at your place?",
      count: 0,
      answers: []
    },
    {
      :code => :weekly_rent,
      label: "Weekly Rent",
      description: "What do you pay in weekly rent?",
      count: 0,
      answers: []
    },
    {
      :code => :monthly_mortgage_repayment,
      label: "Monthly Mortgage Repayment",
      description: "What is your monthly mortgage repayment?",
      count: 0,
      answers: []
    },
    {
      :code => :internet_type,
      label: "Internet Type",
      description: "What kind of internet connection do you have?",
      count: 0,
      answers: []
    },
    {
      :code => :school_completed,
      label: "School Completed",
      description: "Which level of school did you complete?",
      count: 0,
      answers: []
    },
    {
      :code => :level_of_education,
      label: "Level of Education",
      description: "What is your level of education?",
      count: 0,
      answers: []
    },
    {
      :code => :qualifications,
      label: "Qualifications",
      description: "Which area are you qualified in?",
      count: 0,
      answers: []
    },
    {
      :code => :industry_of_employment,
      label: "Industry",
      description: "Which industry are you employed in?",
      count: 0,
      answers: []
    },
    {
      :code => :occupation,
      label: "Occupation",
      description: "Which occupation group are you in?",
      count: 0,
      answers: []
    },
    {
      :code => :weekly_personal_income,
      label: "Weekly Personal Income",
      description: "How much money do you earn?",
      count: 0,
      answers: []
    },
    {
      :code => :travel_to_work,
      label: "Daily Commute",
      description: "How do you get to your place of work?",
      count: 0,
      answers: []
    },
    {
      :code => :religion,
      label: "Religion",
      description: "What religion are you?",
      count: 0,
      answers: []
    }
  ]
}

POPULATION=21507735

australia = data[nil][nil]
questions[:questions].each do |question|
  total = 0
  code = question[:code]
  if code
    australia[code].each do |label, count|
      next if label == 'Other'
      question[:answers] << {
        label: label,
        count: count
      }
    end
  end
  total = question[:answers].reduce(0) { |acc, val| acc + val[:count] }
  question[:count] = POPULATION
  raise if total > POPULATION
  if POPULATION > total
    question[:answers] << {
      label: 'Other / Not Applicable',
      count: POPULATION - total
    }
  end
end

File.open('data/questions.json', 'wb') do |file|
  file.write(MultiJson.dump(questions, pretty: true))
end

#==============================================================================#
