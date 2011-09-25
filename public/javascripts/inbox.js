var Inbox = {
  newMsg : function(){
    $.facebox({ ajax : "/inbox/new", overlay : false });
    return false;
  },

  version : function() {}
}
