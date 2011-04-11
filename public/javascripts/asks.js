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

  dropdown_menu : function(el){
    html = '<ul class="menu">';
    if(ask_redirected == true){
      html += '<li><a onclick="return Asks.redirect_ask_cancel(this);" href="#">取消重定向</a></li>';
    }
    else{
      html += '<li><a onclick="return Asks.redirect_ask(this);" href="#">问题重定向</a></li>';
    }
    $(el).jDialog({
      title_visiable : false,
      width : 160,
      class_name : "dropdown_menu",
      top_offset : -1,
      content : html
    });
    $(el).attr("droped",1);
    return false;
  },

  redirect_ask : function(el){
    if(!logined){
      location.href = "/login";
      return false;
    }
    jDialog.close();
    $.facebox({ div : "#redirect_ask", overlay : false });
    $("#redirect_ask_panel input.search").autocomplete("/search/asks",{
      minChars: 1,
      width: 455,
      scroll : false,
    });
    $("#redirect_ask_panel input.search").result(function(e,data,formatted){
      if(data){
        $("#redirect_ask_panel .r_id").val(data[1]);
        $("#redirect_ask_panel .r_title").val(data[0]);
      }
    });
  },

  redirect_ask_save : function(el){
    App.loading();
    r_id = $("#redirect_ask_panel .r_id").val();
    r_title = $("#redirect_ask_panel input.r_title").val();
    if(r_id.length == ""){
      $("#redirect_ask_panel input.search").focus();
    }
    $.get("/asks/"+ask_id+"/redirect",{ new_id : r_id }, function(res){
        App.loading(false);
        if(res == "1"){
          ask_redirected = true;
          Asks.redirected_tip(r_title,r_id, 'nr', ask_id );
          $.facebox.close();
        }
        else{
          alert("循环重定向，不允许这么关联。");
          return false;
        }
    });
    return false;
  },

  redirect_ask_cancel : function(el){
    $.get("/asks/"+ask_id+"/redirect",{ cancel : 1 });
    Asks.redirected_tip();
    ask_redirected = false;
    jDialog.close();
  },

  redirected_tip : function(title, id, type, rf_id){
    if(title == undefined){
      $("#redirected_tip").remove();
    }
    else{
      label_text = "问题已重定向到: "
      ask_link = "/asks/" + id + "?nr=1&rf=" + rf_id;
      if(type == "rf"){
        label_text = "重定向来自: ";
        ask_link = "/asks/" + id + "?nr=1";
      }
      html = '<div id="redirected_tip"><div class="container">';
      html += '<label>'+label_text+'</label><a href="'+ask_link+'">'+title+'</a>';
      html += '</div></div>';
      $("#main").before(html);
    }
  },


  completeTopic : function(el){
    $(el).autocomplete("/search/topics",{
      minChars: 1,
      width: 200,
      scroll : false,
    });
  },

  beforeSubmitComment : function(el){
    App.loading();
  },

  version : function(){
  }

}

/* 添加问题 */
function addAsk(){      
  if(!logined){
    location.href = "/login";
    return false;
  }
  var txtTitle = $("#hidden_new_ask textarea:nth-of-type(1)");
  ask_search_text = $("#add_ask input").val();
  txtTitle.text(ask_search_text);
  $.facebox({ div : "#hidden_new_ask", overlay : false });
  txtTitle.focus();
  return false;
}

var searchCache = new jCaches(40,false);
var lastSearchText = null;
var lastSearchCompleteHTML = null;
var searchTimer = null;
function showSearchComplete(el,type){
  clearTimeout(searchTimer);
  html = "";
  if(type == "click"){
    if(lastSearchCompleteHTML != null){
      html = lastSearchCompleteHTML;
    }
    else {
      html = "<div class='tip'>"+ $(el).attr("placeholder") + "</div>";
    }
    searchCallback(el,html);
  }
  else{
    searchTimer = setTimeout(function(){
      t = $(el).val().trim();
      if(t == lastSearchText){
        return false;
      }
      lastSearchText = t;
      cachedItems = searchCache.get(t);
      if(cachedItems == null){
        $.ajax({
          url : "/search.json",
          data : { w : t },
          dataType : "json",
          success : function(res){
            searchCache.add(t,res);
            searchAjaxCallback(el,res);
          }
        });
      }
      else{
        searchAjaxCallback(el,cachedItems);
      }
    },200);
  }

  return false;
}

function searchAjaxCallback(el,res){
  App.loading(false);            
  if(res.length > 0){
    html = '<ul class="complete">';
    for(var i=0;i<res.length;i++){
      html += '<li onclick="location.href = $(\'a\',this).attr(\'href\');">';
      item_title = res[i].title;
      item_type = res[i].type;
      if(item_type == "Topic"){
        /* 话题 */
        html += '<a href="/topics/'+res[i].title+'">'+item_title+'</a><span class="type">话题</span>';
      }
      else if(item_type == "User"){
        /* 用户 */
        avatar = res[i].avatar_small;
        if(/http:\/\//.test(avatar) == false){
          avatar = "/images/" + avatar;
        }
        tagline = "";
        if(res[i].tagline != null){
          tagline = res[i].tagline;
        }
        html += '<img class="avatar" src="'+ avatar +'" />';
        html += '<div class="uinfo"><p><a href="/users/'+res[i].slug+'">'+item_title+'</a></p>';
        html += '<p class="tagline">'+tagline+'</p></div>';
      }
      else{
        /* 问题 */
        if(res[i].topics != null){
          if(res[i].topics.length > 0){
            html += '<span class="cate">'+res[i].topics[0]+'</span>';
          }
        }
        html += '<a href="/asks/'+res[i].id+'">'+item_title+'</a>';
      }
      html += '</li>';
    }
    html += '<li class="more" onclick="location.href=\'/search?w='+t+'\';">关于“'+t+'”更多搜索结果...</li>';
    html += "</ul>";
  }
  else{
    html = '<div class="tip">没有找到关于“'+t+'”的结果: <a href="#" onclick="return addAsk();">添加这个问题</a></div>';
  }
  searchCallback(el,html);
}

function searchCallback(el, html){
  lastSearchCompleteHTML = html;
  el_width = $(el).width();
  $(el).jDialog({
    content : html,
    class_name : "search_result_dropdown",
    width : el_width + 250,
    title_visiable : false,
    top_offset : -1,
    left_offset : -1
  });
}
