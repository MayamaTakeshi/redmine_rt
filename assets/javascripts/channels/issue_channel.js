
(function() {
  var base_url = "";

  const adjustMessage = ($message) => {
    //$message.find('.journal-actions, .journal-link').remove();
    $message.find('.journal-actions').remove();
    $message.find("h4").contents().unwrap();

    // Allow at most XXX chars
    const LIMIT = 256
    var wikiChild = $message.find('.wiki');
    var wikiText = wikiChild.text();
    if(wikiText.length > LIMIT) {
      var croppedText = wikiText.substr(0, LIMIT);
      wikiChild.text(croppedText + " ...");
    }
  }

  const fromLoggedInUser = ($message) => {
    const author = $message.find('.user.active').attr('href')

    const logged_in = $('#loggedas').find('.user').attr('href')
    console.log("author_href:", author, "logged_in_href:", logged_in)
    return author == logged_in
  }

  const showMessage = (message) => {
    var $messageContainer = $('#message-container');
    var $message = $(`<div class='message'>${message}<span class='message-dismiss'><b>&times;</b></span></div>`)
    adjustMessage($message)

    if(fromLoggedInUser($message)) {
      console.log(`Message from self. Ignoring.`)
      return
    }

    console.log("message", $message.html())

    $message.appendTo($messageContainer);
    //$messageContainer.appendTo('body');
    //$messageContainer.append('body');
    $message.hide().slideDown(800, () => {
      console.log("animate grow complete")
    })

    var removeMessage = ($message) => {
      $message.slideUp(800, function() {
        console.log("removing message")
        $message.remove();
      });
    }

    var timeout = setTimeout(function() {
      removeMessage($message)
    }, 30000);

    $message.find('.message-dismiss').click(function() {
      clearTimeout(timeout);
      removeMessage($message)
    });
  }

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

    var item_is_visible = function (selectedTabId, item) {
      //item is an array of dom elements. We need to reach the div.journal
      var div = $(item).filter('div.journal').first();
      if(selectedTabId == "tab-notes") {
        console.log("using tab-notes")
        if($(div).hasClass("has-notes")) {
          console.log("hasClass has-notes")
          return true
        } else {
          console.log("not hasClass has-notes")
          return false
        }
      } else if(selectedTabId == "tab-properties") {
        console.log("using tab-properties")
        if($(div).hasClass("has-details")) {
          console.log("hasClass has-details")
          return true
        } else {
          console.log("not hasClass has-details")
          return false
        }
      } else {
        return true
      }
    }
  
    var add_or_update_note = function(id, indice) {

      var $history = $("#history");
  
      var sorting = $history.attr('data-comment_sorting');
  
      var existing_item = indice != null ? true : false;
  
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

        showMessage(data);

        if(existing_item) {
          console.log("existing item");
          $("#note-" + indice).parent().replaceWith(item);
        } else {
          console.log("new item");
          // new item must start as hidden and then we will show it gradually.
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

          var selectedTabId = $("#history .tabs ul li a.selected").attr("id");
          console.log("selectedTabId", selectedTabId);
          if(item_is_visible(selectedTabId, item)) {
            console.log("new item is visible");
            //show new item gradually
            $(item).show(800);
          } else {
            console.log("new item is not visible");
          }
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

      if(msg.type == "issue_saved") {
        if(typeof REDMINE_ISSUE_DYNAMIC_EDIT !== 'undefined') {
          REDMINE_ISSUE_DYNAMIC_EDIT.updateIssueDetails()
        } else {
          var issue_id = window.location.pathname.split("/issues/")[1].split("?")[0];
          const url = base_url + "/issues/" + issue_id
          fetch(url, {
            method: 'GET',
            crossDomain: true,
            })
            .then(res => res.text())
            .then(data => {
              const parser = new DOMParser();
              const doc = parser.parseFromString(data, 'text/html');
              document.querySelector('form#issue-form').innerHTML = doc.querySelector('form#issue-form').innerHTML;
              document.querySelector('#all_attributes').innerHTML = doc.querySelector('#all_attributes').innerHTML;
              document.querySelector('div.issue.details').innerHTML = doc.querySelector('div.issue.details').innerHTML;
          })
        }
      } else if(msg.type == "journal_deleted") {
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
  
