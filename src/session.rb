# Session is a singleton that keeps track of ts3 users currently logged in
# the server. It is used for keeping track of memorizable information about users
# such as whether they re currently talking to cleverbot.
class Session

  RTD_THRESH = 3

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

  def self.update_day
    instance.update_day
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

  # update the current session day
  def update_day
    prev_day = @current_day
    @current_day = Time.now.day
    users.each(&:reset_rtd_count) if prev_day != @current_day
  end

  def users
    @users
  end

  # Fetch all users that have a rtd count that is at most equal to a given
  # threshold.
  #
  # @info: Select all user having a rtd count at most equal to
  #   a given threshold value.
  # @param rtd_count [Integer] max allowed rtd count
  #   user may exhibit in order to be selected
  # @return [Array<User>] a list of users having a rtd count at most eqaul
  #   to a given threshold value.
  def users_with_rtd_count(rtd_count)
    users.select do |user|
      user.rtd_count <= rtd_count
    end
  end

  # Retrieve a random user from the session
  #
  # @return [User, nil] a random user included in the session.
  def random_user
    in_range_users = users_with_rtd_count(RTD_THRESH)
    n = in_range_users.count
    return if n==0
    idx = rand(0..n-1)
    user = in_range_users[idx]
    user.inc_rtd unless user.nil?
    user
  end

  # Add a user to the internal user list.
  #
  # @param user [User] a signed in user.
  def append_to_userlist(user)
    save_in_userlist(user) unless userlist_contains?(user)
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
    update_day
  end

  private

  # Save a human user in the users list.
  #
  # @info: Prevents adding the bot into the session.
  def save_in_userlist(user)
    @users << user unless user.bot?
  end

end
