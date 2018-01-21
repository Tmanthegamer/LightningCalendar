({
	doInit : function(component, event, helper) {
		helper.buildTime(component);
		
		var data = component.get("v.data");
		if(data){
			helper.buildDefault(component, data);	
		}
	},

	onSelectChange : function(component, event, helper) {
		let attr = event.getSource().getLocalId();
		let appt = component.get("v.appt");
		
		let selected = component.find(attr).get("v.value");
		appt[attr] = selected;

		component.set("v.appt", appt);
	},

	prepData : function(component, event, helper) {
		let appt = component.get("v.appt");
		helper.prepareForSave(component, appt);
	},
})