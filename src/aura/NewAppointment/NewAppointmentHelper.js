({
	buildTime : function(component) {
		var hours = [];
		for(var i = 1; i <= 12; i++) {
			hours.push(i);
		}
		var mins = [];
		for(var i = 0; i <= 59; i++) {
			mins.push(i);
		}
		var ampm = ['am', 'pm'];
		component.set("v.hours", hours);
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
			if(hour > 11) {
				ampm = 'pm';
				hour = hour > 12 ? hour-12 : hour;
			}

			appt.min = min;
			appt.hour = hour;
			appt.ampm = ampm;
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

		var hours = appt.hour;
		var adder = appt.ampm == "am" ? 0 : 12;
		endDate.setMinutes(appt.min);
		endDate.setHours(appt.hour + adder+1);

		startDate.setMinutes(appt.min);
		startDate.setHours(appt.hour + adder);

		appt.endTime = this.convertToDateTimeString(component, endDate);
		appt.startTime = this.convertToDateTimeString(component, startDate);
		
		component.set("v.appt", appt);
	},
})