task :default => :test
task :test do
  require 'pry'
  # Testserver data - only works for this test server.
  ENV['P_USER'] = "testserver"
  ENV['P_PASSWORD'] = "9wN1sRuZ"
  ENV['P_PORT'] = "10011"
  ENV['P_IP_ADDRESS'] = "127.0.0.1"

  # spawn new thread such that ts3 can properly run
  Thread.new do
    system("cd test/server && ./ts3server_mac >/dev/null 2>&1")
  end

  # let the server spawn: otherwise it might not have established
  # a proper connection.
  sleep 3

  Dir.glob('./test/*_test.rb').each { |f| require f }
  MiniTest::Unit.after_tests do
    system("ps aux | grep ts3server_mac | xargs kill -9 >/dev/null 2>&1")
    exit(1)
  end
end

task :console do
  require_relative 'pigeon'
  require 'pry'; binding.pry
end
