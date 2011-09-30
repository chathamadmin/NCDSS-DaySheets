Download zip file from github - https://github.com/downloads/chathamadmin/NCDSS-Daysheets/NCDSSDaysheets-v1.0.1.zip


DATABASE SETUP

	Create database named DSSDaysheets.

	Run NCDSSDaysheets-CreateDatabase.sql script in 'database script' folder.

	Alter the spc_get_DaysheetUpload stored procedure to use your county's state assigned Id. To do this, replace the 019 value in the following line "  [CTY-DAY-CTY] = '019',  " with your Id.
	
	Create SQL Server Reporting Services site to use for reporting.

	Add users to tblUser. The userid should be in the form of DOMAIN\Username.
	
	Add existing clients to tblClient.
	


WEBSITE SETUP

Extract website files to desired web folder

Download and install ASP.NETAJAXEXTENSIONS 1.0 from http://www.microsoft.com/downloads/en/details.aspx?FamilyID=ca9d90fa-e8c9-42e3-aa19-08e2c027f5d6&displaylang=en

Add skmParameters and AjaxControlToolkit 2.0 binaries to the bin folder after downloading from the following locations:

http://aspnet.4guysfromrolla.com/code/skmParameters.zip (copy all files from skmParameters\TestWebsite\Bin to website bin folder)
http://ajaxcontroltoolkit.codeplex.com/releases/view/11121#DownloadId=28807 (copy all files from AjaxControlToolkit\SampleWebSite\Bin to website bin folder)

Edit the web.config file. The following values must be entered:
	ftpUploadServer - the state upload server
	organizationName - name of your organization
	fileExportName - name given to file before uploading to the state
	dayOfMonthRecordsLock - the day of the month that the system will lock the previous month's records
	ReportServerURL - the url of the SSRS server
	ReportListView - url of report server that lists the available reports

	If the database instance is not the default instance located on the same server as the website, the following will also need to be updated within the web.config file:
		<add name="DSSDaysheetConnectionString" connectionString="Data Source=.;Initial Catalog=NCDSSDaysheet;Integrated Security=SSPI" providerName="System.Data.SqlClient"/>

		for example, if SQL Express is used, the default instance name is SQLEXPRESS. If the instance is running on the same server, then the Data Source will need to change from "." to ".\SQLEXPRESS". For more information about connection strings, see http://www.connectionstrings.com/.


Set up a website in IIS pointing at the website files folder.

Browse to site making sure that the user you are currently logged in with has an entry in the tblClient table.

As long as everything is working, the only thing to do now is add additional unassigned client id numbers into the system. 
This can be done one at a time, or by uploading a comma delimited text file containing client ids at /sisUplaod.aspx(browse to Admin Menu then Add Clients(SIS # Upload).

