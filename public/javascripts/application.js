// Like Rails DataHelper
var DateHelper = {
  timeAgoInWords: function(from) {
   return this.distanceOfTimeInWords(new Date().getTime(), from);
  },

  distanceOfTimeInWords: function(to, from) {
    seconds_ago = ((to  - from) / 1000);
    minutes_ago = Math.floor(seconds_ago / 60)

    if(minutes_ago == 0) { return "不到一分钟";}
    if(minutes_ago == 1) { return "一分钟";}
    if(minutes_ago < 45) { return minutes_ago + "分钟";}
    if(minutes_ago < 90) { return "大约一小时";}
    hours_ago  = Math.round(minutes_ago / 60);
    if(minutes_ago < 1440) { return hours_ago + "小时";}
    if(minutes_ago < 2880) { return "一天";}
    days_ago  = Math.round(minutes_ago / 1440);
    if(minutes_ago < 43200) { return days_ago + "天";}
    if(minutes_ago < 86400) { return "大约一月";}
    months_ago  = Math.round(minutes_ago / 43200);
    if(minutes_ago < 525960) { return months_ago + "月";}
    if(minutes_ago < 1051920) { return "大约一年";}
    years_ago  = Math.round(minutes_ago / 525960);
    return "超过" + years_ago + "年"
  }
}

var App = {
  
  // 显示进度条
  loading : function(show){
    var loadingPanel = $("#loading");
    if(show == false){
      loadingPanel.hide();
    }
    else{      
      loadingPanel.show();
    }
  },

  /*
   * 检查 Ajax 返回结果的登陆状态，如果是未登陆，就转向登陆页面
   * 此处要配合 ApplicationController 里面的 require_user 使用
   */
  requireUser : function(result, type){
    type = type.toLowerCase();
    if(type == "json"){
      if(result.success == false){
        location.href = "/login";
        return false;
      }
    }
    else{
      if(result == "_nologin_"){
        location.href = "/login";
        return false;
      }
    }
    return true;
  },

  varsion : function(){
    return "1.0";
  }
}
