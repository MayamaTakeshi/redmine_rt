//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});

  App.ws_setup = function(event_handler) {
    App.cable = ActionCable.createConsumer();

    App.cable.subscriptions.create({
      channel: 'RedmineRt::Channel',
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
