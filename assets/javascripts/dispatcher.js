
(function() {
  this.App || (this.App = {});

  App.inactive = false;
 
  var setup = function(event_handler) {
    var channel_name = $('meta[name=page_specific_js]').attr('channel_name');
    console.log("Opening websocket-rails private channel " + channel_name);
    App.dispatcher = new WebSocketRails(window.location.host + '/websocket');
    var private_channel = App.dispatcher.subscribe_private(channel_name, function(current_user) {
      console.log('Websocket-Rails connection and subscription successful');
      private_channel.bind('ALL', event_handler);
    }, function(reason) {
      console.log("Could not connect to channel");
      event_handler(reason);
    });

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

