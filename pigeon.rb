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
require 'user'
require 'server'
