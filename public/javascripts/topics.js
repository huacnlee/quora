var Topics = {
  editCover : function(el){
    $(el).hover(function(){
      $(".edit",$(this)).show();
    }, function(){
      $(".edit",$(this)).hide();
    });
    $(".edit a",$(el)).click(function(el){
        $.facebox({ div : "#edit_topic_cover" });
        return false;
    });
  },

  follow : function(el, id,small){
    App.loading();
    $(el).attr("onclick", "return false;");
    $.get("/topics/"+id+"/follow",{}, function(res){
        $(el).replaceWith('<a href="#" class="flat_button '+small+'" onclick="return Topics.unfollow(this, \''+ id +'\', \''+ small +'\');">取消关注</a>');
        App.loading(false);
    });
    return false;
  },
		
  unfollow : function(el,id,small){
    App.loading();
    $(el).attr("onclick", "return false;");
    $.get("/topics/"+id+"/unfollow",{}, function(res){
        $(el).replaceWith('<a href="#" class="green_button '+small+'" onclick="return Topics.follow(this, \''+ id +'\', \''+ small +'\');">关注</a>');
        App.loading(false);
    });
    return false;
  },
  
  version : function(){}
}
