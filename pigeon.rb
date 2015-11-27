$LOAD_PATH << '.'
$LOAD_PATH << File.expand_path('../src', __FILE__)
$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'java'
require 'teamspeak3-api-1.0.12.jar'

require 'url_store'
require 'url_extractor'
require 'bot'
require 'server_config'
require 'server_group'
require 'command'
require 'command_description'
require 'user'
require 'server'
require 'crawler'
require 'tasks'
require 'command_task'
require 'command_processor'
require 'ot_list'
require 'request_listener'
require 'foreign_message_parser'
