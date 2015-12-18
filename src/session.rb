# Session is a singleton that keeps track of ts3 users currently logged in
# the server. It is used for keeping track of memorizable information about users
# such as whether they re currently talking to cleverbot.
class Session

  def self.instance
    @instance ||= Session.new
  end

  def self.remove_from_userlist(user_id)
    instance.remove_from_userlist(user_id)
  end

  def self.append_to_userlist(user)
    instance.append_to_userlist(user)
  end

  def self.find_user_in_userlist(user_id)
    instance.find_user_in_userlist(user_id)
  end

  def self.random_user
    instance.random_user
  end

  def self.users
    instance.users
  end

  # Load each user that is only into the session's memory.
  #
  # @info: This method is called right after the bot's startup phase.
  #   Used to synchronize the Session memory (ensure consistency).
  #   without doing so, we could only keep track of users that logged into
  #   the server after pigeon has started.
  def self.reload
    User.all.each do |user|
      append_to_userlist(user)
    end
  end

  def users
    @users
  end

  # Retrieve a random user from the session
  #
  # @return [User, nil] a random user included in the session.
  def random_user
    n = @users.count
    return if n==0
    idx = rand(0..n-1)
    @users[idx]
  end

  # Add a user to the internal user list.
  #
  # @param user [User] a signed in user.
  def append_to_userlist(user)
    @users << user unless userlist_contains?(user)
  end

  # Remove a user from the internal user list.
  #
  # @info: We are using a user's id (not its unique id)
  #   use therefore user.id instead of user.unique_id
  # @param u_id [Integer] user id
  def remove_from_userlist(u_id)
    user = find_user_in_userlist(u_id)
    @users.delete(user) unless user.nil?
  end

  # Checks whether a given user is already included in the
  # internal memory list.
  #
  # @param user [User] user that we want to check for.
  # @return [Boolean] true if user is already in the internal list,
  #   false otherwise.
  def userlist_contains?(user)
    !find_user_in_userlist(user.id).nil?
  end

  # Retrieve a user by its id from the internal user
  # list.
  #
  # @info: Can return nil, in case there is no user having an
  #   id value that corresponds to the passed argument.
  # @param u_id [Integer] user id.
  # @return [User] the user that matches the given id.
  def find_user_in_userlist(u_id)
    @users.find do |user|
      user.id == u_id
    end
  end

  def initialize
    @users = []
  end

end
