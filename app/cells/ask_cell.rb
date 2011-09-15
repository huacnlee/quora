class AskCell < Cell::Rails
  helper :users
  cache :relation_asks, :relation_asks_key, :expires_in => 12.hours
  cache :followers, :followers_key

  def relation_asks(opts = {})
    @ask = opts[:ask] || nil
    if @ask
      @relation_asks = Ask.normal.any_in(:topics => @ask.topics).excludes(:id => @ask.id).limit(10).desc("answers_count")
    end
    render
  end

  def followers(opts = {})
    @ask = opts[:ask] || nil
    if @ask
      @followers = @ask.followers
    end
    render
  end

  def invites(opts = {})
    @ask = opts[:ask] || nil
    @current_user = opts[:current_user] || nil
    if @ask
      @invites = @ask.ask_invites.includes(:user)
    end
    render
  end

  private
    def relation_asks_key(opts = {})
      return "relation_asks/nil" if opts[:ask].blank?
      "relation_asks/#{opts[:ask].id}"
    end

    def followers_key(opts = {})
      return "followers/nil" if opts[:ask].blank?
      "followers/#{opts[:ask].id}/#{opts[:ask].follower_ids.to_s.md5}"
    end
end
