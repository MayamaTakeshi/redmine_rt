
(function() {
  this.App || (this.App = {});

  App.inactive = false;
 
  var setup = function(event_handler) {
    console.log("Opening ws connection");
    App.dispatcher = new WebSocketRails(window.location.host + '/websocket');
    var channel = App.dispatcher.subscribe("issue-" + $('meta[name=page_specific_js]').attr('issue_id') + ':messages');
    channel.bind('dummy', event_handler);

    App.dispatcher.bind('connection_closed', function() {
      console.log("ws connection closed");
      if(App.inactive) return;
      setTimeout(function () { 
	setup(event_handler)
      }, 2000);
    });
  };

  App.ws_setup = function(event_handler) {
    setup(event_handler);
  };    

  App.ws_disconnect = function() {
    App.inactive = true;
    App.dispatcher.disconnect();
  };

}).call(this);

