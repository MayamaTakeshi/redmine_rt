(function() {
  function generateUUID() { // Public Domain/MIT
    var d = new Date().getTime();//Timestamp
    var d2 = ((typeof performance !== 'undefined') && performance.now && (performance.now()*1000)) || 0;//Time in microseconds since page-load or 0 if unsupported
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16;//random number between 0 and 16
        if(d > 0){//Use timestamp until depleted
            r = (d + r)%16 | 0;
            d = Math.floor(d/16);
        } else {//Use microseconds since page-load if supported
            r = (d2 + r)%16 | 0;
            d2 = Math.floor(d2/16);
        }
        return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16);
  })
  }

  $(window).on('load', function() {
      var pending = {}
      var bc = new BroadcastChannel("bc_issue")
      bc.addEventListener("message", (event) => {
           var msg = event.data
           console.log(`realtime bc_issue got ${JSON.stringify(msg)}`)
           if(msg.type != 'i_have_it') return
           var item = pending[msg.uuid]
           if(!item) return
           console.log(`Clearing timeout for ${msg}`)
           clearTimeout(item)
           delete pending[msg.uuid]
      })

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
 
      App.ws_setup(function(m) {
          console.log("got msg")
          console.log(m)
          console.dir(m)
          if(m.msg.type == "popup") {
            //TODO need to check the m.msg.user_name or m.msg.user_id
            var url = `${window.location.href.split("/realtime")[0]}/issues/${m.msg.issue_id}`
            console.log(`url to open after timeout ${url}`)
            var item = setTimeout(() => {
              window.open(url, '_blank').focus()
            }, 250)
            var uuid = generateUUID()
            bc.postMessage({
                type: 'anyone?',
                uuid: uuid,
                url: url,
            })
            pending[uuid] = item
          } else if(m.msg.event == "error") {
            App.show_modal("#unauthorized_message")
            App.ws_disconnect();
          } else {
            console.log("unhandled msg")
          }
      });
  })
}).call(this);
  
