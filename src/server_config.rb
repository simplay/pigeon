java_import 'java.util.logging.Level'
java_import 'com.github.theholywaffle.teamspeak3.TS3Config'
require 'java'
require 'pry'
require_relative '../lib/teamspeak3-api-1.0.12.jar'

class ServerConfig
  def initialize
    @config = TS3Config.new
    @config.setDebugLevel(Level::ALL)
    credentials = read_secrets
    @config.setHost(credentials[2])
    @config.setCommandTimeout(1000)
    @config.setQueryPort(credentials[3].to_i)
    @config.setLoginCredentials(credentials[0], credentials[1]);
  end

  def data
    @config
  end

  protected

  # Read sever secrets and stores them in a array.
  #
  # @info: Reader assumes that there exists a file containing all secrets
  #   called 'secrets.txt' located at './secrets/'
  # @return [Array] containing data in the following order
  #   server query admin login name
  #   server query-admin password
  #   server ip address
  #   server password
  def read_secrets
    filepath = "secrets/credentials.txt"
    credentials = []
    File.open(filepath, 'r') do |file|
      while line = file.gets
        credentials << line.chop
      end
    end
    credentials
  end
end