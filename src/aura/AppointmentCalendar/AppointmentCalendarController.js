({
	doInit : function(component, event, helper) {
		helper.attachIframeListener(component, helper);
	},

	scriptsLoaded : function(component, event, helper) {
		helper.getInitData(component);
	},

	build : function(component, event, helper) {
		helper.buildCalendar(component);
	},
	onCancel : function(component, event, helper) {
		component.set("v.showModal", false);
		var msg = { unselect : true };
		helper.postIframeMessage(component, msg);
	},
	onSave : function(component, event, helper) {
		var newAppt = component.find("appt");
		// Make sure our data is good
		newAppt.prepData();

		var appt = newAppt.get("v.appt");

		if(helper.verifyNewAppointment(component, appt)){
			helper.handleSave(component, appt);
		}
	},
})