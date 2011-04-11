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

  follow : function(el, id){
    $(el).attr("onclick", "return false;");
    $.get("/topics/"+id+"/follow",{}, function(res){
        $(el).replaceWith('<a href="#" style="width:80px;" class="gray_button" onclick="return Topics.unfollow(this, \''+ topic_id +'\');">取消关注</a>');
    });
    return false;
  },
		
  unfollow : function(el,id){
    $(el).attr("onclick", "return false;");
    $.get("/topics/"+id+"/unfollow",{}, function(res){
        $(el).replaceWith('<a href="#" style="width:80px;" class="gray_button green_button" onclick="return Topics.follow(this, \''+ topic_id +'\');">关注此话题</a>');
    });
    return false;
  },
  
  version : function(){}
}
