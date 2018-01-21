({
    attachIframeListener : function(component, helper) {
        var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
        var messageEvent = eventMethod === "attachEvent" ? "onmessage" : "message";
        
        var eventer = window[eventMethod];
        eventer(messageEvent, function (e) {
            if (e) {
                helper.handleIframeMessage(component, e);
            }
        });
    },

    handleIframeMessage : function(component, event) {
        var data = event.data;
        if(data === "hello"){
            //initialize the appointments
            this.getInitData(component);
        }
        else if(data) {
            var obj = null;
            try {
                obj = JSON.parse(data);
            }
            catch(exception){
                console.log('bad message');
            }
            if(obj){
                this.handleNewAppointment(component, data);
            }
        }
    },

    handleNewAppointment : function(component, eventDataJSON) {
        var eventData = JSON.parse(eventDataJSON);
        if(eventData && eventData.start && eventData.end){
            if(this.isOnWeekend(component, eventData) === false){
                this.showNewAppointmentModal(component, eventData);
            }
        }
        else {
            alert('eventdata invalid');
            console.log('JSON', eventDataJSON, 'OBJ', eventData);
        }
    },

    verifyNewAppointment : function(component, newAppt) {
        let appointments = component.get("v.appointments");
        let isValid = true;
        for (var i = appointments.length - 1; i >= 0; i--) {
            let oldAppt = appointments[i];
            if(this.hasTimeOverlap(component, oldAppt, newAppt)){
                isValid = false;
            }
        }

        if(!isValid){
            isValid = confirm("Are you sure you want to double book this time?");
        }
        return isValid;
    },

    isOnWeekend : function(component, eventData) {
        let start = this.convertToProperDate(component, eventData.start);
        let end = this.convertToProperDate(component, eventData.end);

        if(start.getDay() === 0 || start.getDay() === 6 || 
            end.getDay() === 0 || end.getDay() === 6 ) {

            alert('You are not allowed to book weekdays, relax instead');
            return true; 
        }
        return false;
    },

    hasTimeOverlap : function(component, oldAppt, newAppt){
        let oldStart = this.convertToProperDate(component, oldAppt.Start_Time__c);
        let oldEnd = this.convertToProperDate(component, oldAppt.End_Time__c);
        let newStart = this.convertToProperDate(component, newAppt.startTime);
        let newEnd = this.convertToProperDate(component, newAppt.endTime);

        let newStartTime = newStart.getTime();
        if(newStartTime >= oldStart.getTime() && newStartTime < oldEnd.getTime()-1) {
            return true;
        }

        let newEndTime = newEnd.getTime();
        if(newEndTime >= oldStart.getTime() && newEndTime < oldEnd.getTime()-1) {
            return true;
        }

        return false;
    },

    showNewAppointmentModal : function(component, eventData) {
        component.set("v.data", eventData);
        var newAppt = component.find("appt");
        newAppt.init();

        component.set("v.showModal", true);
    },

    postIframeMessage : function(component, data) {
        var dataJSON = JSON.stringify(data);
        var vfOrigin = component.get("v.vfHost");
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(dataJSON, vfOrigin);
    },

    getInitData : function(component) {
        var action = component.get("c.getInitData");
        let recordId = component.get("v.recordId");
        action.setParams({ 
            recordId : recordId 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            let result = response.getReturnValue();
            if (state === "SUCCESS" && result) {
                this.handlePostInit(component, result);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    handlePostInit : function(component, result) {
        let lead = result.lead;
        let appointments = result.appointments;
        let eventDataJSON = result.eventDataJSON;
        let subjects = result.subjects;
        let displayAs = result.displayAs;

        component.set("v.lead", lead);
        component.set("v.appointments", appointments);
        
        // Give newAppt the proper picklist values
        var newAppt = component.find("appt");
        newAppt.set("v.subjects", subjects);
        newAppt.set("v.displayAs", displayAs);

        let data = JSON.parse(eventDataJSON);
        this.postIframeMessage(component, data);
    },

    handleSave : function(component, appt) {
        var action = component.get("c.createAppointment");
        let recordId = component.get("v.recordId");
        action.setParams({ 
            recordId : recordId,
            apptJSON : JSON.stringify(appt)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            let result = response.getReturnValue();
            if (state === "SUCCESS" && result) {
                console.log(result);
                this.navigateToOpp(component, result);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    navigateToOpp : function(component, recordId) {
        var navEvt = $A.get( 'e.force:navigateToSObject' );
        if(recordId) {      
            if(navEvt){
                navEvt.setParams({
                  "recordId": recordId
                });
                navEvt.fire();
            }
            else {
                // Let Salesforce figure out where we need to go
                window.location = '/' + recordId;
            }
        }
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
        return properDate;
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
})