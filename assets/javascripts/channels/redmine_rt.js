
console.log("p1");
if(window.location.pathname.indexOf("/issues/") >= 0) {
  console.log("p2");
	this.App = {};

  console.log("p3");
	App.cable = ActionCable.createConsumer();

  console.log("p4");

  console.log("p5");
	App.messages = App.cable.subscriptions.create('MessagesChannel', {
		received: function(data) {
       console.log("got message");
			console.dir(data);
		}
	});
}
