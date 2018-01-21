<aura:application extends="force:slds">
	<aura:attribute name="recordId" type="String" />

	<c:CreateAppointment recordId="{!v.recordId}"/>

</aura:application>