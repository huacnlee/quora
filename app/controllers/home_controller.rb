# coding: utf-8
class HomeController < ApplicationController
  before_filter :require_user_text, :only => [:update_in_place]
  before_filter :require_user

  def index
    @per_page = 20
    @asks = Ask.normal.includes(:user,:last_answer,:last_answer_user,:topics)
                  .exclude_ids(current_user.muted_ask_ids)
                  .desc(:answered_at,:id)
                  .paginate(:page => params[:page], :per_page => @per_page)

    if params[:format] == "js"
      render "/asks/index.js"
    end
  end
  
  def followed
    @per_page = 10
    @asks = current_user ? current_user.followed_asks : Ask.normal
    @asks = @asks.includes(:user,:last_answer,:last_answer_user,:topics)
                  .exclude_ids(current_user.muted_ask_ids)
                  .desc(:answered_at,:id)
                  .paginate(:page => params[:page], :per_page => @per_page)

    if params[:format] == "js"
      render "/asks/index.js"
    else
      render "index"
    end
  end

  # 查看用户不感兴趣的问题
  def muted
    @per_page = 10
    @asks = Ask.normal.includes(:user,:last_answer,:last_answer_user,:topics)
                  .only_ids(current_user.muted_ask_ids)
                  .desc(:answered_at,:id)
                  .paginate(:page => params[:page], :per_page => @per_page)

    set_seo_meta("我屏蔽掉的问题")

    if params[:format] == "js"
      render "/asks/index.js"
    else
      render "index"
    end
  end



  def update_in_place
    klass, field, id = params[:id].split('__')
    object = klass.camelize.constantize.find(id)
    if object.update_attributes(field => params[:value])
      render :text => object.send(field).to_s
    else
      render :text => object.errors.full_messages.join("\n"), :status => 422
    end
  end

end
