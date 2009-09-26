Ext.ux.ChatPanel = Ext.extend(Ext.grid.GridPanel, {

	exchange: null,

	data: [
		['Name','Message', new Date()]
	],

	initComponent: function() {

		var store = new Ext.data.ArrayStore({
			fields: [
				{name: 'name', type: 'string'},
				{name: 'message', type: 'string'},
				{name: 'when', type: 'date'}
			]
		});
		store.loadData(this.data);

		Ext.apply(this, {
			store: store,
			stripeRows: false,
			columns: [
				{header: "When", width: 50, sortable: true, dataIndex: 'when', renderer: Ext.util.Format.dateRenderer('h:i') },
				{header: "Name", width: 80, sortable: true, dataIndex: 'name'},
				{header: "Message", id: "msg", width: 75, sortable: false, dataIndex: 'message'}
			],
			autoExpandColumn: 'msg',
			bbar: {
				items: [{
					id: "writer",
					xtype: 'textfield',
					width: 400,
					enableKeyEvents: true,
					listeners: {
						scope: this,
						keyup: function(f,e) {
							if(e.getKey() == e.ENTER) {
								this.send();
							}
						}
					}
				},'-',{
					xtype: 'button',
					text: "Send",
					scope: this,
					handler: this.send
				},'->',{
					id: "user",
					xtype: 'textfield',
					width: 100,
					value: "Nub"
				}]
			}
		});
		
		//wire up the AMQPClient
		MQ.queue("auto").bind("chat").callback(this.onMessage.createDelegate(this));

		Ext.ux.ChatPanel.superclass.initComponent.apply(this, arguments);
	},
	
	send: function() {
		var writer = this.getWriterField();
		var message = writer.getValue();
		writer.setValue("");
		
		MQ.exchange("chat").publish({name: this.getUserName(), message: message});
	},
	
	onMessage: function(m) {
		m.data.when = new Date();
		var record = new this.store.recordType(m.data);
		this.store.addSorted(record);
		
		this.scrollToBottom();
	},
	
	scrollToBottom: function() {
		var d = this.getView().scroller.dom;
		d.scrollTop = d.scrollHeight - d.offsetHeight;
		d.scrollLeft = 0;
	},
	
	getWriterField: function() {
		return this.getBottomToolbar().get("writer");
	},
	
	getUserName: function() {
		return this.getBottomToolbar().get("user").getValue();
	}
});

Ext.ComponentMgr.registerType('chatPanel', Ext.ux.ChatPanel);