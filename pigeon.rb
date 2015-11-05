#!/usr/bin/env ruby

$LOAD_PATH << '.'
$LOAD_PATH << File.expand_path('../src', __FILE__)
$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'java'
require 'teamspeak3-api-1.0.12.jar'

require 'bot'
require 'bot_manager'
require 'server_config'
require 'command'
require 'url_store'

BotManager.new if __FILE__ == $PROGRAM_NAME
