(function() {

if(window.location.pathname.indexOf("/issues/") >= 0) {

  var remove = function(id) {
    var item = $("#change-" + id);
    item.hide(800, function() {
      // Animation complete.
      item.remove();
    });
  };

  var add = function(id) {
    $.get( "/journals/" + id, function( data ) {
      var item = $.parseHTML(data);
      $(item).css('display', 'none');
      $("#history").append(item);
      $(item).show(800);
    });
  };

  App.messages = App.cable.subscriptions.create('RedmineRt::MessagesChannel', {
    received: function(msg) {
      console.log("got msg");
      console.log(msg);
      if(msg.type == "journal_deleted") {
        remove(msg.journal_id);
      } else if(msg.type == "journal_saved") {
        var $item = $("#change-" + msg.journal_id);
        if($item.length == 0) {
          console.log("element absent. Adding it")
          add(msg.journal_id); 
        } else {
          console.log("element already exists");
        }
      }
    }
  });
}

}).call(this);

