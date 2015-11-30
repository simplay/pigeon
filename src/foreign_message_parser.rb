require 'json'
require 'digest/sha1'

# ForeignMessageParser extracts all relevant information from a foreing message
# if it is valid and privileged.
#
# assumes that a given foreign message is a valid hash parsed to json containing the
# following 3 keys:
#   :header: indicating what type of message was send
#   :content: the actual message
#   :secret: a passphrase that should match the internal pigeon passphrase.
#     the passphrase is supposed to be in SHA1. A foreign message will be further processed,
#     if and only if the provided encrypted passphrass matches the internal encrypted passphrase.
#
# @info: a message is considered as invalid if either the passphrases do not match or
#   the message does not exhibit the required hash keys.
#
# @example of a possbile foreign message:
#   input_msg =
#     {:secret => e173e39778e21084d7d2063209c3596c4dbe4542, :header => :text, :content => "pew"}
#
#   Note that we are actually working with input_msg.to_json.
class ForeignMessageParser

  # @param input_msg [String] a JSON serialized ruby hash
  #   containing a header, the secret and some content.
  # @example
  #   "{"header":"MYHEADER","secret":"SOMEFANCYKEY","content":"MESSAGE"}"
  def initialize(input_msg)
    @input_msg = input_msg
    @passphrase = to_sha1(ENV['P_SECRET'])
    parse
  end

  def parsed_message
    @parsed_msg
  end

  def msg_content
    parsed_message['content']
  end

  def msg_header
    parsed_message['header']
  end

  def got_valid_message?
    includes_req_token?
  end

  private

  def to_sha1(secret)
    raise "ENV variable P_SECRET not set." if secret.nil?
    Digest::SHA1.hexdigest(secret)
  end

  def successfully_parsed?
    @has_parsable_msg
  end

  def includes_req_token?
    return false unless successfully_parsed?
    received_secret = parsed_message['secret']
    received_secret == @passphrase
  end

  def parse
    begin
      @parsed_msg = JSON.parse(@input_msg)
    rescue JSON::ParserError
      @has_parsable_msg = false
    end
    @has_parsable_msg = msg_contains_req_keys?
  end

  def msg_contains_req_keys?
    ['header', 'content', 'secret'].all? do |req_key|
      @parsed_msg.keys.include? req_key
    end
  end

end
