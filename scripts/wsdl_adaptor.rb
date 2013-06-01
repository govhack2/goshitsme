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

#------------------------------------------------------------------------------#




# create a client for the service
wsdl_client = Savon.client(wsdl: 'http://stat.abs.gov.au/sdmxws/sdmx.asmx?WSDL')

puts wsdl_client.operations
# => [ :get_data_structure_definition, :get_generic_data, :get_compact_data, :get_metadata, :get_dataset_metadata,
#      :get_dimension_metadata, :get_dimension_member_metadata, :get_metadata_structure, :get_reference_metadata ]


# call the 'get_compact_data' operation
# response = wsdl_client.call(:get_compact_data)

# response.body
# => { find_user_response: { id: 42, name: 'Hoff' } }



#==============================================================================#
