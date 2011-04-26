var Users = {
  follow : function(el, id, small){
    App.loading();
    $(el).attr("onclick", "return false;");
    $.get("/users/"+id+"/follow",{}, function(res){
        $(el).replaceWith('<a href="#" class="flat_button '+small+'" onclick="return Users.unfollow(this, \''+ id +'\',\''+small+'\');">取消关注</a>');
        App.loading(false);
    });
    return false;
  },
  unfollow : function(el, id, small){
    App.loading();
    $(el).attr("onclick", "return false;");
    $.get("/users/"+id+"/unfollow",{}, function(res){
        $(el).replaceWith('<a href="#" class="green_button '+small+'" onclick="return Users.follow(this, \''+ id +'\',\''+small+'\');">关注</a>');
        App.loading(false);
    });
    return false;
  },

  /* 不感兴趣推荐的用户或话题 */
  mute_suggest_item : function(el, type, id){
    $(el).parent().parent().fadeOut("fast");
    $.get("/mute_suggest_item", { type : type, id : id },function(res){
        App.requireUser(res);
    });
    return false;
  },

  varsion : function(){}
}
