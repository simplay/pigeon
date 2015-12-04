require 'pstore'

# OtList maintains a list of all users that should receive a private message by Sir Pigeon
# whenever they join the ts3 server.
# This list is kept in Memory as well as it is stored in a file, loaded during Pigeon's startup.
# Whenever a user is either added or removed from this list, both, the file and the
# in memory list are updated accordingly.
#
# The ot db uses a user's id as the key.
# Equality of users it checked by comparing their nicknames.
# Therefore, by changing the nickname, the user cannot be retrieved in the db.
#
# @TODO: When a user changes his name (when logged in, update all lists accordingly).
class OtList

  # Helper class to define a simplified notion of user instances
  # that only repsond to their id and nickname attributes.
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

  # Adds a user to the ot list.
  #
  # @info: users are added on a local subscribers list AND
  #  in the ot subscriber table.
  #  Ot users get informed when joining the ts3 server.
  #  Users only get added once to the list.
  # @param user [User] user to add to the ot list.
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

  # @return [Array<OtUser>] all stored users contained in the ot list.
  def all_stored
    store.transaction do
      store.roots.flat_map do |u_id|
        store.fetch(u_id, [])
      end
    end
  end

  # Removes a user from the ot list.
  #
  # @info: Removing a user means that he is removed from the -
  #   in the runtime present - subscribers list and from the ot db file.
  # @param user [User] user to be removed from the ot list.
  def remove(user)
    user = find(user)
    unless user.nil?
      @subscribers.delete(user)
      store.transaction do
        store.delete(user.id)
      end
    end
  end

  # Is a given user included in the ot subscriber list?
  #
  # @param user [#nick]
  def include?(user)
    !find(user).nil?
  end

  # Checks whether a given user is contained in the subscriber list.
  #
  # @info: compares two users by their nickname value
  # @param user [#nick] the user we want to check for.
  def find(user)
    @subscribers.find do |subscriber|
      subscriber.nick == user.nick
    end
  end

  # Checks the ot file db whether a given user id is contained.
  #
  # @return [Boolean] is true if the user is included and false otherwise.
  def find_in_db(u_id)
    store.transaction do
      store.fetch(u_id, [])
    end
  end

  # Brute force reset internal subscription list and associated file.
  def flush
    @subscribers = []
    all_stored.each do |usr|
      store.transaction do
        store.delete(usr.id)
      end
    end
  end

  private

  # Initially, load all users that are contained in the file db into the
  # in runtime active subscriber list.
  def initialize
    @subscribers = all_stored
  end

  # File containing the ot list db.
  def store
    @file_db ||= PStore.new('data/ot_list.pstore')
  end

end
