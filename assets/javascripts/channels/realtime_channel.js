(function() {
  $(window).on('load', function() {
      var user_name = $('meta[name=page_specific_js]').attr('user_name')
      console.log("user_name: " + user_name)

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

      App.ws_setup(function(msg) {
          console.log("got msg")
          console.log(msg)
          console.dir(msg)
          if(msg.event == "error") {
            App.show_modal("#unauthorized_message")
            App.ws_disconnect();
          } else if(msg.command == "open_url") {
            window.open(msg.data.url, '_blank').focus()
          } else {
            console.log("unhandled msg")
          }
      });
  })
}).call(this);
  
