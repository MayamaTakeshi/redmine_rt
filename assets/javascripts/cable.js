//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});

  App.ws_setup = function(event_handler) {

    var url = window.location.href
    var base_url = ""
    var channel_name = ""
    if(url.includes('/issues/')) {
        base_url = url.split('/issues/')[0]
        channel_name = $('meta[name=page_specific_js]').attr('channel_name')
    } else if(url.endsWith('/realtime') || url.endsWith('realtime/')) {
        var user_name = $('meta[name=page_specific_js]').attr('user_name')
        channel_name = "user:" + user_name
    }

    App.cable = ActionCable.createConsumer(base_url + "/cable");

    App.cable.subscriptions.create({
      channel: 'Channel',
      name: channel_name
    }, 
    {
    	received: event_handler
    });
  };

  App.ws_disconnect = function() {
    App.cable.disconnect();
  };

}).call(this);
