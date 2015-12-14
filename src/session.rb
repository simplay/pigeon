# Runtime teamspeak 3 session used to keep track of user states.
# Are they talking to sir pigeon, ...
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

  def self.reload
    User.all.each do |user|
      append_to_userlist(user)
    end
  end

  def append_to_userlist(user)
    @users << user unless userlist_contains?(user)
  end

  def remove_from_userlist(u_id)
    user = find_user_in_userlist(u_id)
    @users.delete(user) unless user.nil?
  end

  def userlist_contains?(user)
    !find_user_in_userlist(user.id).nil?
  end

  def find_user_in_userlist(u_id)
    @users.find do |user|
      user.id == u_id
    end
  end

  def initialize
    @users = []
  end

end
