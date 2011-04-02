# coding: utf-8
class LogsController < ApplicationController
  def index
    @per_page = 10
    @logs = Log.desc("$natural").paginate(:page => params[:page], :per_page => @per_page)
  end
end