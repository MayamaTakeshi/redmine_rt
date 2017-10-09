//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();

  App.ws_subscribe = function(event_handlers) {
    App.cable.subscriptions.create({
      channel: 'RedmineRt::MessagesChannel',
      issue_id: $('meta[name=page_specific_js]').attr('issue_id')
    },
    event_handlers)
  };

  App.ws_disconnect = function() {
    App.cable.close();
  }

}).call(this);
