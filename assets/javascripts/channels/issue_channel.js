(function() {
  var base_url = "";

  $(window).on('load', function() {
      if(window.location.pathname.indexOf("/issues/") >= 0) {
        base_url = window.location.href.split("/issues/")[0];
      }
      
      $('#quick_notes_ta').each(function () {
        this.setAttribute('style', 'height:' + (this.scrollHeight) + 'px;overflow-y:hidden;');
      }).on('input', function () {
        this.style.height = 'auto';
        this.style.height = (this.scrollHeight) + 'px';
      });
      
      if( $("#history").attr("data-comment_sorting") == "asc") {
        // move div quick_notes to bottom of div history
        $("#quick_notes").insertAfter( $("#history") );
      }

      App.show_modal = function(id) {
        $( id ).dialog({
          modal: true,
          buttons: {
            Ok: function() {
              $( this ).dialog( "close" );
            }
          }
        });
      }
      
      console.log("SETTING ON CLICK");
      $('#quick_notes_btn').click(function(e) {
        console.log("clicked");
        e.stopPropagation();
        e.preventDefault();
        if (e.handled == true) {
          return;
        }
        e.handled = true;
        var $ta = $('#quick_notes_ta');
        if($ta.val().trim() == '') {
          return;
        }
        var data = {
          issue: {
            notes: $ta.val(),
            private_notes: $("#quick_notes_private_cbox").is(":checked") ? true : false
          }
        };
      
        console.log("sending PUT");

        var issue_id = window.location.pathname.split("/issues/")[1].split("?")[0];
        $.ajax({
          url: base_url + "/issues/" + issue_id + "/add_quick_notes",
          method: 'PUT',
          dataType: "text", // Expected type of server response body
          contentType: 'application/json; charset=utf-8',
          data: JSON.stringify(data),
          success: function(response) {
            console.log("PUT succcess");
            $ta.val('');
            $ta.removeData('changed');
          },
          error: function(textStatus, err) {
            console.log("PUT failed: " + textStatus);
            console.dir(err);
      
            App.show_modal("#operation_failed_message");
          }
        });
      });
  });
  
  if(window.location.pathname.indexOf("/issues/") >= 0) {
  
    var remove = function(id) {
      var item = $("#change-" + id);
      item.hide(800, function() {
        // Animation complete.
        item.remove();
      });
    };
  
    var add_or_update_note = function(id, indice) {
      var $history = $("#history");
  
      var sorting = $history.attr('data-comment_sorting');
  
      var existing_note = indice != null ? true : false;
  
      var last;
  
      var $history_children = $history.find("> div");
      if( sorting == 'desc') {
        $last = $history_children.last();
      } else {
        $last = $history_children.first();
      }
  
      if(!indice) {
        indice = 1;
        if($last.length > 0) {
          var journal_id = $last.find("div[id|='note']").attr("id");
          if(journal_id) {	
            indice = parseInt(journal_id.split("-")[1]) + 1;
          }
        }
      }
  
      $.get(base_url + "/journals/" + id + "?indice=" + indice, function( data, statusText, jqXHR ) {
        console.log("GET /journals got statusText=" + statusText);
  
        console.log(lock_version);
        var lock_version = jqXHR.getResponseHeader("X-issue-lock-version");
  
        $("#issue_lock_version").attr("value", lock_version);
  
        var item = $.parseHTML(data);

        /*
        $(item).find('a').each(function() {
          var audio_suffixes = ['wav', 'mp3', 'ogg'];
          var suffix = $(this).attr('href').split('.').pop();
          if(audio_suffixes.indexOf(suffix) >= 0) {
            $(this).replaceWith("<audio controls preload='none'><source src=" + $(this).attr('href') + "/></audio>")
          }
        });
        */
  
        if(existing_note) {
          console.log("existing note");
          $("#note-" + indice).parent().replaceWith(item);
        } else {
          console.log("new note");
          $(item).css('display', 'none');
  
          if( sorting == 'desc') {
            var container = $("#tab-content-history");
            if(container) {
                // redmine 4.2 and newer
                container.prepend(item);
            } else {
                // redmine 4.1 and older
                $(item).insertBefore($history.find("h3"));
            }
          } else {
            var container = $("#tab-content-history");
            if(container) {
                // redmine 4.2 and newer
                container.append(item);
            } else {
                // redmine 4.1 and older
                $(item).insertAfter($history.find("h3"));
            }
          }
          $(item).show(800);
        }
      }).fail(function(jqXHR, error, reason) {
        console.log(error)
        if(reason == "Unauthorized") {
          App.show_modal("#unauthorized_message");
        }
     });
    };

    App.ws_setup(function(msg) {
      console.log("got msg");
      console.log(msg);
      if(msg.type == "journal_deleted") {
        remove(msg.journal_id);
      } else if(msg.type == "journal_saved") {
        var $item = $("#change-" + msg.journal_id);
        if($item.length == 0) {
          console.log("element " + msg.journal_id + " absent. Adding it")
          add_or_update_note(msg.journal_id); 
          $("#last_journal_id").attr("value", msg.journal_id);
        } else {
          console.log("element already exists");
          var indice = $item.find("div[id|='note']").attr("id").split("-")[1];
          add_or_update_note(msg.journal_id, indice); 
        }
      } else if(msg.event == "error") {
        App.show_modal("#unauthorized_message");
        App.ws_disconnect();
      }
    });
  } 
}).call(this);
  
