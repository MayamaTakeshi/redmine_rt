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
    var $history = $("#history");

    var sorting = $history.attr('data-comment_sorting');

    var last;

    var $history_children = $history.find("> div");
    if( sorting == 'desc') {
      $last = $history_children.last();
    } else {
      $last = $history_children.first();
    }

    var indice = 1;
    if($last.length > 0) {
      indice = parseInt($last.find("div").attr("id").split("-")[1]) + 1;
    }

    $.get( "/journals/" + id + "?indice=" + indice, function( data ) {
      var item = $.parseHTML(data);
      $(item).css('display', 'none');

      if( sorting == 'desc') {
        $history.append(item);
      } else {
        $(item).insertAfter($history.find("h3"));
      }
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

