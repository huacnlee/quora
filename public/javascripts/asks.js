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

	simple_follow : function(el,id){
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

	simple_unfollow : function(el,id){
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
    html += '<li><a onclick="return Asks.report(this);" href="#">举报</a></li>';
    $(el).jDialog({
      title_visiable : false,
      width : 160,
      class_name : "dropdown_menu",
      top_offset : -2,
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
      delay: 50,
      width: 456,
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

  /* 问题，话题，人搜索自动完成 */
  completeAll : function(el){
    input = $(el);
    input.autocomplete("/search/all",{
      mincChars: 1,
      delay: 50,
      width: 580,
      scroll : false,
      selectFirst : false,
      clickFire : true,
      hideOnNoResult : false,
      noResultHTML : "没有找到类似的内容，<a href='#' onclick='return addAsk();'>添加一个问题</a>",
      formatItem : function(data, i, total){
        klass = data[data.length - 1];
        switch(klass){
          case "Ask":
            return Asks.completeLineAsk(data, true);
            break;
          case "Topic":
            return Asks.completeLineTopic(data, true);
            break;
          case "User":
            return Asks.completeLineUser(data, true);
            break;
          default:
            return "";
            break;
        }
      }
    }).result(function(e, data, formatted){
        url = "/";
        klass = data[data.length - 1];
        switch(klass){
          case "Ask":
            url = "/asks/" + data[1];
            break;
          case "Topic":
            url = "/topics/" + data[0];
            break;
          case "User":
            url = "/users/" + data[4];
            break;
        }
        location.href = url;
        return false;
      });
  },

  completeTopic : function(el){
    $(el).autocomplete("/search/topics",{
      minChars: 1,
      delay: 50,
      width: 200,
      scroll : false,
      formatItem : function(data, i, total){
        return Asks.completeLineTopic(data,false);
      }
    });
  },

  toggleShareAsk : function(el,type){
    $(el).parent().find("a").removeClass("actived");
    klass = $(el).attr("class");
    if(klass.length > 0){
      if(klass.split(" ").indexOf("actived")){
        return false;
      }
    }
    $(el).addClass("actived");
    if(type == "share"){
      $(el).parent().parent().find(".inner .invite").hide();
      $(el).parent().parent().find(".inner .share").show();
    }
    else{
      $(el).parent().parent().find(".inner .share").hide();
      $(el).parent().parent().find(".inner .invite").show();
      $.facebox.close();
    }
		return false;
  },

  /* 邀请人回答问题 */
  completeInviteToAnswer : function(){
    input = $("#ask_to_answer");
    input.autocomplete("/search/users", {
      mincChars: 1,
      delay: 50,
      width: 206,
      scroll : false,
      formatItem : function(data, i, total){
        return Asks.completeLineUser(data,false);
      }
    });
    input.result(function(e,data,formatted){
      if(data){
        user_id = data[1];
        name = data[0];
        Asks.inviteToAnswer(data[1]);
      }
    });
  },

  /* 取消邀请 */
  cancelInviteToAnswer : function(el, id){
    var countp = $(el).parent().find(".count");
    count = parseInt(countp.text());
    if(count > 1){
      count -= 1
      countp.text(count);
    }
    else{
      $(el).parent().parent().fadeOut().remove();
    }
    $(el).before('<span class="n"></span>');
    $(el).remove();
    $.get("/asks/"+ask_id+"/invite_to_answer",{ i_id : id, drop : 1 });
    return false;
  },
  
  inviteToAnswer : function(user_id, is_drop){
    App.loading();
    $.get("/asks/"+ask_id+"/invite_to_answer.js",{ user_id : user_id, drop : is_drop });
  },

  completeLineTopic : function(data,allow_link){
    html = "";
    cover = data[2];
    if(/http:\/\//.test(cover) == false){
      cover = "";
    }
    count = data[1];
    if(cover.length > 0){
      html += '<img class="avatar" src="'+ cover +'" />';
    }
    html += '<div class="uinfo"><p>';
    if(allow_link == true){
      html += '<a href="/topics/'+data[0]+'">'+ data[0] +'</a>';
    }
    else{
      html += '<span class="name">'+data[0]+'</span>';
    }
    html += '<span class="scate">话题</span>';
    html += '</p>';
    html += '<p class="count">'+count+' 个关注者</p></div>';
    return html;
  },

  completeLineAsk : function(data, allow_link){
    if(allow_link == false){
      return data[0]
    }
    
    html = "";
    if(data[2] != null){
      topics = data[2].split(",")
      if(topics.length > 0){
        html += '<span class="cate">'+topics[0]+'</span>';
      }
    }
    html += '<a href="/asks/'+data[1]+'">'+data[0].replace("/","")+'</a>';
    return html;
  },

  completeLineUser : function(data,allow_link){
    html = "";
    avatar = data[3];
    if(/http:\/\//.test(avatar) == false){
      avatar = "/images/" + avatar;
    }
    tagline = data[2];
    html += '<img class="avatar" src="'+ avatar +'" />';
    html += '<div class="uinfo"><p>';
    if(allow_link == true){
      html += '<a href="/users/'+data[5]+'">'+data[0]+'</a>';
    }
    else{
      html += '<span class="name">'+data[0]+'</span>';
    }
    html += '</p>';
    html += '<p class="tagline">'+tagline+'</p></div>';
    return html;
  },



  beforeSubmitComment : function(el){
    App.loading();
  },

  thankAnswer : function(el,id){
    klasses = $(el).attr("class").split(" ");
    if(klasses.indexOf("thanked") > 0){
      return false;
    }
    $(el).addClass("thanked");
    $(el).text("已感谢");
    $(el).click(function(){ return false });
    $.get("/answers/"+id+"/thank");
    return false;
  },

  spamAsk : function(el, id){
    if(!confirm("多人评价为烂问题后，此问题将会被屏蔽，而且无法撤销！\n你确定要这么评价吗？")){
      return false;
    }

    App.loading();
    $(el).addClass("spamed");
    $.get("/asks/"+id+"/spam",function(count){
      if(!App.requireUser(count,"text")){
        return false;
      }
      $("#ask_spam_count").val(count);
      App.loading(false);
    });
    return false;
  },

  beforeAnswer : function(el){
    $("button.submit",el).attr("disabled","disabled");
    App.loading();
  },

  spamAnswer : function(el, id){
    App.loading();
    $(el).addClass("spamed");
    $(el).text("已提交");
    $.get("/answers/"+id+"/spam",function(count){
      if(!App.requireUser(count,"text")){
        return false;
      }
      App.loading(false);
    });
    return false;
  },

  toggleEditTopics : function(isShow){
    if(isShow){
      $(".ask .edit_topics").show();
      $(".ask .item_list").hide();
    }
    else{
      $(".ask .item_list").show();
      $(".ask .edit_topics").hide();
    }
  },

  beforeAddTopic : function(el){
    App.loading();
  },

  addTopic : function(name){
    App.loading(false);
    if(name.trim() == ""){
      return false;
    }
    $(".ask .topics .item_list .in_place_edit").before("<a href='/topics/"+name+"' class='topic'>"+name+"</a>");
    $(".ask .topics .item_list .no_result").remove();
    exit_topic_count = $(".ask .edit_topics .items .topic").length;
    $(".ask .edit_topics .items").append('<div class="topic"> \
          <a href="#" onclick="Asks.removeTopic(this,'+(exit_topic_count+1)+',\''+name+'\');" class="remove"></a>\
          <span>'+name+'</span>\
        </div>');
  },

  removeTopic : function(el, idx, name){
    App.loading();
    $.get("/asks/"+ask_id+"/update_topic", { name : name }, function(res){
      $(el).parent().remove();
      $(".ask .topics .item_list .topic:nth-of-type("+(idx+1)+")").remove();
      App.loading(false);
    });
    return false;
  },

  follow : function(el){
    App.loading();
    $(el).attr("onclick", "return false;");
    $.get("/asks/"+ask_id+"/follow",{}, function(res){
      App.loading(false);
      $(el).replaceWith('<a href="#" style="width:80px;" class="flat_button" onclick="return Asks.unfollow(this);">取消关注</a>');
    });
    return false;
  },

  unfollow : function(el){
    App.loading();
    $(el).attr("onclick", "return false;");
    $.get("/asks/"+ask_id+"/unfollow",{}, function(res){
      App.loading(false);
      $(el).replaceWith('<a href="#" style="width:80px;" class="gray_button green_button" onclick="return Asks.follow(this);">关注此问题</a>');
    });
    return false;
  },

  toggleComments : function(type, id){
    var el = $("#"+type+"_"+id);
    var comments = $(".comments",el);
    if(comments.length > 0){
      comments.toggle();
    }
    else{
      App.loading();
      $.get("/comments",{ type : type, id : id }, function(html){
        $(".action",el).after(html);
        App.loading(false);
      });
    }
    return false;
  },

  vote : function(id, type){
    var answer = $("#answer_"+id);
    vtype = "down";
    if(type == 1) { vtype = "up"; }
    $(".vote_buttons a",answer).removeClass("voted");
    $(".vote_buttons a.vote_"+vtype,answer).addClass("voted");
    $(".action a",answer).removeClass("voted");
    $(".action a.vote_"+vtype,answer).addClass("voted");
    App.loading();
    $.get("/answers/"+id+"/vote",{ inc : type },function(res){
      if(!App.requireUser(res,"text")){
        return false;
      }
      res_a = res.split("|");
      Asks.vote_callback(id, vtype, res_a[0], res_a[1]);
      App.loading(false);
    });
    return false;
  },

  vote_callback : function(id, vtype, new_up_count, new_down_count){
    var answer = $("#answer_"+id);
    var answer_votes = $(".votes",answer);
    answer.attr("data-uc", new_up_count);
    answer.attr("data-dc", new_down_count);
    
    /* Change value for visable label */
    if(answer_votes.length > 0){
      if(new_up_count <= 0){
        /* remove up vote count label if up_votes_count is zero */
        $(answer_votes).remove();
      }
      else{
        $(".num",answer_votes).text(new_up_count);
      }
    }
    else {
      if(vtype == "up"){
        $(".author",answer).after("<div class=\"votes\"><span class=\"num\">"+new_up_count+"</span> 票</div>");
      }
    }

    var answers = $(".answer");
    var position_changed = false;

    for(var i =0;i<answers.length;i++){
      a = answers[i];
      /* Skip current voted Answer self */
      if($(a).attr("id") == answer.attr("id")){
        continue;
      }
      /* Get next Answer uc and dc */
      u_count = parseInt($(a).attr("data-uc"));
      d_count = parseInt($(a).attr("data-dc"));

      /* Change the Ask position */
      if(vtype == "up"){
        if(new_up_count > u_count){
          $(a).before(answer);
          position_changed = true;
          break;
        }
      }
      else{
        /* down vote */
        if(new_up_count <= u_count && new_down_count < d_count){
          $(a).after(answer);
          position_changed = true;
          break;
        }
      }
    }
    answer.fadeOut(100).fadeIn(200);
  },

  report : function(){
    $.facebox({ div : "#report_page", overlay : false });
    jDialog.close();
    return false;
  },

  showSuggestTopics : function(topics){
    html = '<div id="ask_suggest_topics" class="ask"><div class="container"><label>根据您的问题，我们推荐这些话题(点击添加):</label>';
    for(var i=0;i<topics.length;i++) {
      html += '<a href="#" class="topic" onclick="return Asks.addSuggestTopic(this,\''+topics[i]+'\');">'+topics[i]+'</a>';
    }
    html += '<a class="gray_button small" href="#" onclick="return Asks.closeSuggestTopics();">完成</a>';
    html += "</div></div>";
    $("#main").before(html);
  },

  addSuggestTopic : function(el,name){
    App.loading();
    var csrf = App.getCSRF();
    $.ajax({
      url : "/asks/"+ask_id+"/update_topic.js?"+ csrf.key + "=" + csrf.value,
      data : {
        name : name,
        add : 1
      },
      dataType : "text",
      type : "post",
      success : function(res){
        App.loading(false);
        Asks.addTopic(name);
        $(el).remove();
        if($("#ask_suggest_topics a.topic").length == 0){
          $("#ask_suggest_topics").remove();
        }
      }
    });
    return false;
  },
  
  closeSuggestTopics : function(){
    $("#ask_suggest_topics").fadeOut("fast",function(){ $(this).remove(); });
    return false;
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
  txtTitle.focus();
  $.facebox({ div : "#hidden_new_ask", overlay : false });
  return false;
}

