class AskCell < Cell::Rails
  helper :users
  cache :relation_asks, :relation_asks_key, :expires_in => 12.hours
  cache :followers, :followers_key

  def relation_asks(opts = {})
    @ask = opts[:ask] || nil
    if @ask
      @relation_asks = Ask.normal.any_in(:topics => @ask.topics).excludes(:id => @ask.id).limit(10).desc("$natural")
    end
    render
  end

  def followers(opts = {})
    @ask = opts[:ask] || nil
    @followers = @ask.followers
    render
  end

  private
    def relation_asks_key(opts = {})
      return "relation_asks/nil" if opts[:ask].blank?
      "relation_asks/#{opts[:ask].id}"
    end

    def followers_key(opts = {})
      return "followers/nil" if opts[:ask].blank?
      "followers/#{opts[:ask].id}/#{opts[:ask].followers.to_s.md5}"
    end
end
