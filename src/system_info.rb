require 'java'
java_import 'java.lang.System'

# SystemInformation provides runtime information such as on which os Pigeon is running
# or by whom it is called (either from the console or by an exectuable jar).
class SystemInfo

  attr_reader :os, :caller

  CALLER_JAR = 'jar'
  CALLER_CONSOLE = 'console'

  def self.singleton
    @instance ||= SystemInfo.new
  end

  # Does pigeon run on a mac?
  #
  # @return [Boolean] true if pigeon is run on a mac os and false otherwise.
  def self.running_on_mac?
    singleton.os.include?('mac')
  end

  # Does pigeon run on a windows os?
  #
  # @return [Boolean] true if pigeon is run on a windows os and false otherwise.
  def self.running_on_windows?
    singleton.os.include?('windows')
  end

  # Does pigeon run on a linux os?
  #
  # @return [Boolean] true if pigeon is run on a linux os and false otherwise.
  def self.running_on_linux?
    singleton.os.include?('linux')
  end

  # Is pigeon called by an exectuable jar?
  #
  # @return [Boolean] true if pigeon is called by its exectuable jar and false otherwise.
  def self.called_by_jar?
    singleton.caller == CALLER_JAR
  end

  # Is pigeon called from a console?
  #
  # @return [Boolean] true if pigeon is called within the console and false otherwise.
  def self.called_by_console?
    singleton.caller == CALLER_CONSOLE
  end

  private

  def initialize
    caller_name = "#{$PROGRAM_NAME}"
    @caller = caller_name.include?("<script>") ? CALLER_JAR : CALLER_CONSOLE
    @os = System.getProperty("os.name").downcase
  end

end
