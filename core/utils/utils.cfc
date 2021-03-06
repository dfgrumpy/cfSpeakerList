<cfcomponent displayname="utils">

	<!---                          --->
	<!--- DATABASE DATA ENCRYPTION --->
	<!---                          --->
	<cffunction name="dataEnc" access="public" returntype="string">
		<cfargument name="value" type="string" required="yes" hint="I am the value to encrypt for the database." />
		<cfargument name="mode" type="string" required="false" default="db" />
		
		<!--- var scope --->
		<cfset var onePass = '' />
		<cfset var twoPass = '' />
		<cfset var lastPass = '' />
		
		<!--- check if the passed value has length --->
		<cfif Len(ARGUMENTS.value)>
		
			<!--- it does, check if the mode of the encryption is 'db' --->
			<cfif FindNoCase('db',ARGUMENTS.mode)>
			
				<!--- using database encryption, encrypt with the first set of keys and algorithm --->
				<cfset onepass = Encrypt(ARGUMENTS.value,APPLICATION.dbkey1,APPLICATION.dbalg1,APPLICATION.dbenc1) />
				<!--- and again with the second set of keys and algorithm --->
				<cfset twopass = Encrypt(onepass,APPLICATION.dbkey2,APPLICATION.dbalg2,APPLICATION.dbenc2) />
				<!--- and again with the third set of keys and algorithm --->
				<cfset lastPass = Encrypt(twopass,APPLICATION.dbkey3,APPLICATION.dbalg3,APPLICATION.dbenc3) />
				<!--- NOTE: Add additional passes here for greater security --->
			
			<!--- otherwise, check if the mode of the encryption is 'url' --->
			<cfelseif FindNoCase('url',ARGUMENTS.mode)>
			
				<!--- using url encryption, encrypt with the first set of keys and algorithm --->
				<cfset lastPass = Encrypt(ARGUMENTS.value,APPLICATION.dbkey1,APPLICATION.dbalg1,APPLICATION.dbenc1) />
				
			<!--- otherwise, check if the mode of the encryption is 'form' --->
			<cfelseif FindNoCase('form',ARGUMENTS.mode)>
			
				<!--- using form encryption, encrypt with the second set of keys and algorithm --->
				<cfset lastPass = Encrypt(ARGUMENTS.value,APPLICATION.dbkey2,APPLICATION.dbalg2,APPLICATION.dbenc2) />
				
			<!--- otherwise, check if the mode of the encryption is 'cookie' --->
			<cfelseif FindNoCase('cookie',ARGUMENTS.mode)>
			
				<!--- using cookie encryption, encrypt with the first set of keys and algorithm --->
				<cfset lastPass = Encrypt(ARGUMENTS.value,APPLICATION.dbkey3,APPLICATION.dbalg3,APPLICATION.dbenc3) />
			
			<!--- end checking if the mode of the encryption is 'db', 'url', 'form' or 'cookie' --->	
			</cfif>
		
		<!--- end checking if the passed value has length --->
		</cfif>
		
		<!--- return the encrypted value (or null if passed value has no length) --->
		<cfreturn lastPass>
	</cffunction>

	<!---                          --->
	<!--- DATABASE DATA DECRYPTION --->
	<!---                          --->
	<cffunction name="dataDec" access="public" returntype="string">
		<cfargument name="value" type="string" required="yes" hint="I am the value to decrypt for the database.">
		<cfargument name="mode" type="string" required="false" default="db" />

		<!--- var scope --->
		<cfset var onePass = '' />
		<cfset var twoPass = '' />
		<cfset var lastPass = '' />
		
		<!--- check if the passed value has length --->
		<cfif Len(ARGUMENTS.value)>
		
			<!--- it does, check if the mode of the encryption is 'db' --->
			<cfif FindNoCase('db',ARGUMENTS.mode)>
	
				<!--- NOTE: Add additional passes here for greater security --->
				<!--- using database encryption, decrypt with the third set of keys and algorithm --->
				<cfset var onePass = Decrypt(ARGUMENTS.value,APPLICATION.dbkey3,APPLICATION.dbalg3,APPLICATION.dbenc3) />
				<!--- and again with the second set of keys and algorithm --->
				<cfset var twoPass = Decrypt(onepass,APPLICATION.dbkey2,APPLICATION.dbalg2,APPLICATION.dbenc2) />
				<!--- and again with the first set of keys and algorithm --->
				<cfset var lastPass = Decrypt(twopass,APPLICATION.dbkey1,APPLICATION.dbalg1,APPLICATION.dbenc1) />
			
			<!--- otherwise, check if the mode of the encryption is 'url' --->
			<cfelseif FindNoCase('url',ARGUMENTS.mode)>
			
				<!--- using url encryption, decrypt with the first set of keys and algorithm --->
				<cfset lastPass = Decrypt(ARGUMENTS.value,APPLICATION.dbkey1,APPLICATION.dbalg1,APPLICATION.dbenc1) />
				
			<!--- otherwise, check if the mode of the encryption is 'form' --->
			<cfelseif FindNoCase('form',ARGUMENTS.mode)>
			
				<!--- using form encryption, decrypt with the second set of keys and algorithm --->
				<cfset lastPass = Decrypt(ARGUMENTS.value,APPLICATION.dbkey2,APPLICATION.dbalg2,APPLICATION.dbenc2) />
				
			<!--- otherwise, check if the mode of the encryption is 'cookie' --->
			<cfelseif FindNoCase('cookie',ARGUMENTS.mode)>
			
				<!--- using cookie encryption, decrypt with the first set of keys and algorithm --->
				<cfset lastPass = Decrypt(ARGUMENTS.value,APPLICATION.dbkey3,APPLICATION.dbalg3,APPLICATION.dbenc3) />
			
			<!--- end checking if the mode of the encryption is 'db', 'url', 'form' or 'cookie' --->	
			</cfif>
		
		<!--- end checking if the passed value has length --->
		</cfif>

		<!--- return the decrypted value (or null if passed value has no length) --->
		<cfreturn lastPass>
	</cffunction>
	
	<!---                      --->
	<!--- GLOBAL ERROR HANDLER --->
	<!---                      --->
	<cffunction name="errorHandler" access="public" returntype="void" output="true">
		<cfargument name="errorData" type="any" required="true" hint="I am the struct returned by cfcatch." />
		<cfargument name="debug" type="boolean" required="false" default="#APPLICATION.debugOn#" hint="I determine whether to fail gracefully or output debug." />
		
		<!--- check if we're failing gracefully --->
		<cfif NOT ARGUMENTS.debug>
		
			<!--- we are, output an error message --->
			<script type="text/javascript">
				document.removeChild(document.documentElement);
			</script>
			<h1>We're sorry but an error has occurred. Please refresh your browser to try again.</h1>
			
		<!--- otherwise --->
		<cfelse>
		
			<!--- dump there error to the screen --->
			<cfdump var="#ARGUMENTS.errorData#" label="ERROR DATA (CFCATCH)" />
			<!--- and abort --->
			<cfabort>
		
		<!--- end checking if we're failing gracefully --->
		</cfif>	
		
	</cffunction>

	<!---                      --->
	<!--- SANITIZE FORM VALUES --->
	<!---                      --->
	<cffunction name="sanitize" access="public" returntype="struct" output="false" hint="I sanitize data passed in a FORM scope using either ESAPI or HTMLEditFormat().">
		<cfargument name="formData" type="struct" required="true" hint="I am the FORM struct." />
		
		<!--- var scope --->
		<cfset var formField = '' />
		<cfset var returnStruct = StructNew() />
		
		<!--- loop through the FORM fields provided --->
		<cfloop collection="#ARGUMENTS.formData#" item="formField">
			<!--- check if this is a boolean or numeric value --->
			<cfif IsBoolean(formField) OR IsNumeric(formField)>
				<!--- it is, so just add it to the return struct --->
				<cfset returnStruct[formfield] = ARGUMENTS.formData[formfield] />
			<!--- otherwise --->
			<cfelse>
				<!--- not boolean or numeric, check if we're using ESAPI --->
				<cfif APPLICATION.useESAPI>
					<!--- we are, process the form field through ESAPI --->
					<cfset returnStruct[formField] = APPLICATION.esapiEncoder.encodeForHTML(ARGUMENTS.formData[formfield]) />
				<!--- otherwise --->
				<cfelse>
					<!--- we're not using ESAPI, process the form field through HTMLEditFormat() --->
					<cfset returnStruct[formField] = HTMLEditFormat(ARGUMENTS.formdata[formfield]) />
				<!--- end checking if we're using ESAPI --->
				</cfif>
			<!--- end checking if this is a boolean or numeric value --->
			</cfif>
		<!--- end looping through the FORM fields provided --->
		</cfloop> 
		
		<!--- return the sanitzed form values --->
		<cfreturn returnStruct />
		
	</cffunction>
	
	<!---                       --->
	<!--- CHECK REQUIRED FIELDS --->
	<!---                       --->
	<cffunction name="checkRequired" access="public" returntype="struct" output="false" hint="I take a struct of fields and values and ensure they are not blank (null).">
		<cfargument name="fields" type="struct" required="true" hint="I am a struct of the fields to check." />
		
		<!--- var scope --->
		<cfset var formField = '' />
		<cfset var returnStruct = StructNew() />
		
		<!--- set the result of this check to true by default (all required fields provide values) --->
		<cfset returnStruct.result = true />
		<cfset returnStruct.fields = '' />
		
		<!--- loop through the passed in struct --->
		<cfloop collection="#ARGUMENTS.fields#" item="formField">
			<!--- check if this field has length --->
			<cfif NOT Len(ARGUMENTS.fields[formField])>
				<!--- it doesn't have a length, add it to the list of fields that did not provide value) --->
				<cfset returnStruct.fields = ListAppend(returnStruct.fields,formField) />
				<!--- and se the result of this check to false (not all required fields provide values) --->
				<cfset returnStruct.result = false />
			<!--- end checking if this field has length --->
			</cfif>
		<!--- end looping through the passed in struct --->
		</cfloop>
		
		<!--- return the results of the required check (true/false and any missing fields) --->
		<cfreturn returnStruct />
		
	</cffunction>
		
</cfcomponent>