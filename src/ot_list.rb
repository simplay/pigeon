require 'pstore'

# OtList maintains a list of all users that should receive a private message by Sir Pigeon
# whenever they join the ts3 server.
# This list is kept in Memory as well as it is stored in a file, loaded during Pigeon's startup.
# Whenever a user is either added or removed from this list, both, the file and the
# in memory list are updated accordingly.
class OtList

  class OtUser
    attr_reader :id, :nick
    def initialize(id, nick)
      @id = id
      @nick = nick
    end
  end

  def self.instance
    @instance ||= OtList.new
  end

  def self.append(user)
    instance.append(user)
  end

  def self.remove(user)
    instance.remove(user)
  end

  def self.include?(user)
    instance.include?(user)
  end

  def self.find(user)
    instance.find(user)
  end

  def append(user)
    unless include?(user)
      u_id = user.id
      ot_usr = OtUser.new(u_id, user.nick)
      @subscribers << ot_usr
      store.transaction do
        ot_list = store[u_id] ||= []
        ot_list << ot_usr
      end
    end
  end

  # @return [Array<Url>]
  def all_stored
    store.transaction do
      store.roots.flat_map do |u_id|
        store.fetch(u_id, [])
      end
    end
  end

  def remove(user)
    user = find(user)
    unless user.nil?
      @subscribers.delete(user)
      store.transaction do
        store.delete(user.id)
      end
    end
  end

  def include?(user)
    !find(user).nil?
  end

  # compares two users by their id value
  def find(user)
    @subscribers.find do |subscriber|
      subscriber.nick == user.nick
    end
  end

  def find_in_db(u_id)
    store.transaction do
      store.fetch(u_id, [])
    end
  end

  # brute force reset internal subscription list and associated file.
  def flush
    @subscribers = []
    all_stored.each do |usr|
      store.transaction do
        store.delete(usr.id)
      end
    end
  end

  private

  def initialize
    @subscribers = all_stored
  end

  def store
    @file_db ||= PStore.new('ot_list.pstore')
  end

end
