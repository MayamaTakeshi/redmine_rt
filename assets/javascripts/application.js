
if(window.location.pathname.indexOf("/issues/") >= 0) {

  var remove = function(id) {
    var item = $("#change-" + id);
    item.animate({
      left: 0,
      height: 0
    }, 8000, function() {
      // Animation complete.
      item.remove();
    });
  };

  var add = function(id) {
    $.get( "/journals/" + id, function( data ) {
      var item = $.parseHTML(data);
      $("#history").append(item);
    });
  };

  this.App = {};

  App.cable = ActionCable.createConsumer();

  App.messages = App.cable.subscriptions.create('MessagesChannel', {
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
