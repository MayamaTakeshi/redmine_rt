//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});

  App.ws_setup = function(event_handler) {

    var base_url = window.location.href.split("/issues/")[0]

    App.cable = ActionCable.createConsumer(base_url + "/cable");

    App.cable.subscriptions.create({
      channel: 'Channel',
      name: $('meta[name=page_specific_js]').attr('channel_name')
    }, 
    {
    	received: event_handler
    });
  };

  App.ws_disconnect = function() {
    App.cable.disconnect();
  };

}).call(this);
