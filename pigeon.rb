$LOAD_PATH << '.'
$LOAD_PATH << File.expand_path('../src', __FILE__)
$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'java'
require 'teamspeak3-api-1.0.12.jar'
require 'cleverbot.jar'

require 'settings'
require 'url_store'
require 'url_extractor'
require 'bot'
require 'server_config'
require 'server_group'
require 'channel'
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
require 'mailbox'
require 'event'
require 'chatbot_factory'
require 'timed_task'
require 'periodic_task'
require 'text_block'
require 'description_layout'
require 'system_info'
require 'bootstrap'
require 'description_link_store'
