({
	buildTime : function(component) {
		var hours = [];
		var AMhours = [];
		var PMhours = [];
		for(var i = 1; i <= 12; i++) {
			if(i >= 6) AMhours.push(i);
			if(i <= 7) PMhours.push(i);
		}
		var mins = [];
		for(var i = 0; i <= 59; i++) {
			mins.push(i);
		}
		var ampm = ['am', 'pm'];
		component.set("v.hours", AMhours);
		component.set("v.AMhours", AMhours);
		component.set("v.PMhours", PMhours);
		component.set("v.mins", mins);
		component.set("v.ampm", ampm);
	},

	// Doing this to stop timezone shenanigans
	convertToProperDate : function(component, date) {
		var theDate = date.split('T')[0]; // "2018-01-15"
		var theTime = date.split('T')[1]; // "15:00:00.000Z"

		var dateSplit = theDate.split("-");
		var timeSplit = theTime.split(":");

		var properDate = new Date(
				dateSplit[0], 
				parseInt(dateSplit[1])-1, 
				dateSplit[2], 
				timeSplit[0], 
				timeSplit[1], 
				"" + parseInt(timeSplit[2], 10)
		);
		console.log(properDate);
		return properDate;
	},

	buildDefault : function(component, data) {
		var appt = {};
		var hours = component.get("v.hours");
		var mins = component.get("v.mins");
		var ampm = component.get("v.ampm");
		var subjects = component.get("v.subjects");
		var displayAs = component.get("v.displayAs");

		// data.end is not used but still given
		// if(data.end){

		// }

		if(data.start){
			var properDate = this.convertToProperDate(component, data.start);
			appt.start = this.convertToDateString(component, properDate);
			appt.startTime = this.convertToDateTimeString(component, properDate);


			var min = properDate.getMinutes();
			var hour = properDate.getHours();
			var ampm = 'am';
			var hoursToDisplay = component.get("v.AMhours");
			if(hour > 11) {
				ampm = 'pm';
				hour = hour > 12 ? hour-12 : hour;
				hoursToDisplay = component.get("v.PMhours");
			}

			component.set("v.min", min);
			component.set("v.hour", hour);
			component.set("v.timeOfDay", ampm);
		}
		if(subjects && subjects.length) {
			appt.subject = subjects[0];
		}
		if(displayAs && displayAs.length) {
			appt.displayAs = displayAs[0];
		}
		component.set("v.appt", appt);
	},

	convertToDateString : function(component, date) {
		var newDate = new Date(date);
		var dateString = (newDate.getMonth() + 1) + "-" + newDate.getDate() + "-" + newDate.getFullYear();
		return dateString;
	},

	pad : function(number) {
		var numStr = "" + number;
		return numStr.length < 2 ? "0" + numStr : numStr;
	},

	convertToDateTimeString : function(component, date) {
		var newDateTime = new Date(date);
		// 2018-01-16T19:30:00.000Z
		var dateString = 
				newDateTime.getFullYear() + '-' 
				+ this.pad((newDateTime.getMonth() + 1)) + '-' 
				+ this.pad(newDateTime.getDate())+ 'T' 
				+ this.pad(newDateTime.getHours()) + ':'
				+ this.pad(newDateTime.getMinutes()) + ':'
				+ '00.000Z';
		return dateString;
	},

	prepareForSave : function(component, appt) {
		var endDate = new Date(appt.start);
		var startDate = new Date(appt.start);

		var min = component.get("v.min");
		var hour = component.get("v.hour");
		var timeOfDay = component.get("v.timeOfDay");

		var mins = parseInt(min, 10);
		var hours = parseInt(hour, 10);
		var adder = timeOfDay === "am" ? 0 : 12;
		endDate.setMinutes(mins);
		endDate.setHours(hours + adder + 1);

		startDate.setMinutes(mins);
		startDate.setHours(hours + adder );

		appt.endTime = this.convertToDateTimeString(component, endDate);
		appt.startTime = this.convertToDateTimeString(component, startDate);
		appt.min = mins;
		appt.hour = hours;
		appt.ampm = timeOfDay;
		
		component.set("v.appt", appt);
	},

	adjustAvailableTimes : function(component, ampm) {
		var AMhours = component.get("v.AMhours");
		var PMhours = component.get("v.PMhours");
		var hours = component.get("v.hours");
		var appt = component.get("v.appt");

		var hourToUse = null;

		if(ampm === "am" && hours[0] !== 6) {
			component.set("v.hours", AMhours);
			hourToUse = AMhours[0];
		}
		else if(ampm === "pm" && hours[0] !== 1) {
			component.set("v.hours", PMhours);
			hourToUse = PMhours[0];
		}

		if(hourToUse) component.set("v.hour", hourToUse);
	}
})