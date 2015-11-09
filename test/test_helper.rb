require 'minitest/autorun'
require 'minitest/pride'
require 'yaml'
require_relative '../pigeon'

credentials = YAML.load_file('test/test_server_credentials.yml')

# Testserver data
ENV['P_USER'] = credentials.fetch('user', 'serveradmin')
ENV['P_PASSWORD'] = credentials.fetch('password')
ENV['P_PORT'] = credentials.fetch('port', '10011').to_s
ENV['P_IP_ADDRESS'] = credentials.fetch('ip', '127.0.0.1')

# spawn new thread such that ts3 can properly run
Thread.new do
  system("cd test/server && ./ts3server_mac >/dev/null 2>&1")
end

# let the server spawn: otherwise it might not have established
# a proper connection.
sleep 3

# kill all ts3 servers when we're done testing
Minitest.after_run do
  system("ps aux | grep ts3server_mac | xargs kill -9 >/dev/null 2>&1")
  exit(1)
end
