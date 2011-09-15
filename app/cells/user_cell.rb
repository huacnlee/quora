class UserCell < Cell::Rails
  helper :users
  cache :followers, :followers_key, :expires_in => 3.days
  cache :following, :following_key, :expires_in => 3.days

  def followed_topics(opts = {})
    @user = opts[:user] || nil
    @current_user = opts[:current_user] || nil
    if @user
      @followed_topics = @user.followed_topics.desc("$natural").limit(7)
    end
    render
  end

  def followers(opts = {})
    @user = opts[:user] || nil
    if @user
      @followers = @user.followers.desc("$natural").limit(42)
    end
    render
  end

  def following(opts = {})
    @user = opts[:user] || nil
    if @user
      @following = @user.following.desc("$natural").limit(42)
    end
    render
  end

  private
    def followers_key(opts = {})
      return "followers/nil" if opts[:user].blank?
      "followers/#{opts[:user].id}/#{opts[:user].follower_ids.to_s.md5}"
    end

    def following_key(opts = {})
      return "following/nil" if opts[:user].blank?
      "following/#{opts[:user].id}/#{opts[:user].following_ids.to_s.md5}"
    end
end
