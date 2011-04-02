var Asks = {
  mute : function(el,id){
    App.loading();
    $.get("/asks/"+id+"/mute",{}, function(res){
        App.loading(false);
        if(!App.requireUser(res,"text")){
          return false;
        }
        // $(el).replaceWith('<span class="muted">不再显示</span>');
				$(el).parent().parent().fadeOut("fast");
    });
    return false;
  },

	unmute : function(el,id){
    App.loading();
    $.get("/asks/"+id+"/unmute",{}, function(res){
        App.loading(false);
        if(!App.requireUser(res,"text")){
          return false;
        }
        // $(el).replaceWith('<span class="muted">不再显示</span>');
				$(el).parent().parent().fadeOut("fast");
    });
    return false;
  },

	follow : function(el,id){
    App.loading();
    $.get("/asks/"+id+"/follow",{}, function(res){
        App.loading(false);
        if(!App.requireUser(res,"text")){
          return false;
        }
        $(el).replaceWith('<span class="muted">已关注</span>');
				// $(el).parent().parent().fadeOut("slow");
    });
    return false;
  },

	unfollow : function(el,id){
    App.loading();
    $.get("/asks/"+id+"/unfollow",{}, function(res){
        App.loading(false);
        if(!App.requireUser(res,"text")){
          return false;
        }
        // $(el).replaceWith('<a href="/asks'+id+'/follow">关注</a>');
				$(el).parent().parent().fadeOut("fast");
    });
    return false;
  },

  version : function(){
  }

}
