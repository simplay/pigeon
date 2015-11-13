$LOAD_PATH << '.'
$LOAD_PATH << File.expand_path('../src', __FILE__)
$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'java'
require 'teamspeak3-api-1.0.12.jar'

require 'url_store'
require 'url_extractor'
require 'bot'
require 'bot_manager'
require 'server_config'
require 'command'
require 'command_description'
require 'user'
require 'server'
require 'crawler'
require 'tasks'
require 'command_task'
require 'command_processor'
