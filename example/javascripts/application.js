//the main application object, exposed globally
var Application;
var MQ;
var DemoExchange;

//the application class, used for loading panels, and handling navigation
Ext.Application = Ext.extend(Ext.Viewport, {

	initComponent: function() {

		Ext.apply(this,{
			layout: 'vbox',
			border: false,
			renderTo: 'application-view',
			layoutConfig: {
				align : 'stretch'
			},
			defaults: {
				border: false,
				flex: 1,
				anchor: "100% 50%",
				layout: 'hbox',
				layoutConfig: {
					align : 'stretch'
				},
				defaults: {
					flex  : 1,
					margins: "2 2 2 2"
				}
			},
			
			items: [{
				items: [{
					xtype: 'panel',
					title: 'Group Music - Disabled'
					
				},{
					xtype: 'interactiveGridPanel',
					title: 'Increment Updates'
				}]
			},{
				items: [{
					xtype: 'chatPanel',
					title: 'Chat'
				},{
					xtype: 'logPanel',
					title: 'Logging'
				}]
			
			}]
		});
		
		Ext.Application.superclass.initComponent.apply(this, arguments);
	},
	
	messageReceived: function(msg) {
	}
});

//this is the first code executed after the dom is fully
//rendered and ready to go
Ext.onReady(function() {

	Velveteen.initialize({
		connection: {
			host: "amqp.peermessaging.com"
		},
		logLevel: 1
	});
	
	swfobject.embedSWF(
		"swiffs/AMQPFlash.swf",
		"amqp_flash",
		"1",
		"1",
		"9",
		"swiffs/expressInstall.swf",
		{},
		{
			wmode: 'opaque',
			bgcolor: '#ff0000'
		},
		{}
	);

	Ext.QuickTips.init();

	Application = new Ext.Application();

	Velveteen.addListener("ready", function() {
		MQ = new MessageQueue({
			callback: Application.messageReceived
		});
		DemoExchange = new Exchange({
			declare: {
				exchange: "demo",
				type: "topic"
			}
		});
	});
	
	Ext.get("loading").remove();
	Ext.get("loading-mask").fadeOut();

});



