<##############################################################################

File:		Send-DataHubTopic.ps1
Name:		Send-DataHubTopic

Purpose:	This function Invokes notifications.

Params:		

Called by:	Windows Scheduler - SSIS DataHub packages.
Calls:		n/a  

Errors:		

Author:		ffortunato
Date:		20180424
Version:    1.0.0.7

###############################################################################

       CHANGE HISTORY

###############################################################################

Date		Author			Description

########	##########      ###################################################

20180424	ffortunato		Initial iteration.

##############################################################################>



function Send-DataHubTopic {

<#

.SYNOPSIS
This function is used by Data Hub processes to notify the service bus of a new publication being staged.

.DESCRIPTION
...

.PARAMETER connectionString
Connection string for the services bus. Includes authentication.

.PARAMETER ConnectionString
The user name that will be used for authentication to the host.



.EXAMPLE
Send-DataHubTopic `
    -remoteDir "\\bpe-aesd-cifs\BI_Admin_dev\FileShare\OIE\outbound\" `
    -destDir   "\\bpe-aesd-cifs\BI_Admin_dev\FileShare\OIE\inbound\" `
    -pubnc  "BEHAVE" 
    

#>

    [CmdletBinding(
        SupportsShouldProcess=$True
    )]
    param (

		[parameter(Mandatory=$true,
		Position = 0)]
		[alias("con")]
		[string]$ConnectionString = 'N/A'
<#
		,[parameter(Mandatory=$true,
		Position = 0)]
		[alias("t")]
		[string]$Topic = -1
#>
		,[parameter(Mandatory=$true,
		Position = 1)]
		[alias("DistId")]
		[int]$DistributionId = -1

		,[parameter(Mandatory=$true,
		Position = 2)]
		[alias("IssId")]
		[int]$IssueId = -1

		,[parameter(Mandatory=$true,
		Position = 3)]
		[alias("subnc","sc")]
		[string]$subscriptionCode = 'N/A'
)
begin
{

} #begin
process
{
	$date      = Get-Date
	$curDate   = Get-Date  -format "yyyy/MM/dd HH:mm:ss"
	$labelDate = Get-Date  -format "yyyyMMddHHmmss"
	$dateU     = $date.ToUniversalTime()
	$curUser   = whoami
	$script    = $MyInvocation.MyCommand.Name
	$hostName  = hostname

	$connectionString = 'Endpoint=sb://bpiedubi.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=U7svfsaVcN47Fo8sVZ6Ax1Y8k/JeYVky/ny65+aze8s='
	$topic = 'dh-publication-ready'

	try
	{
	# get the parameters into a hash table that well comprise the properties of the sent message.
		$msgProperties = @{
			DistributionId=$DistributionId
			IssueId=$IssueId
			SubscriptionCode=$subscriptionCode
			Script=$script
			CreatedDtm=$curDate
			CreatedDtmUTC=$dateU
			CreatedBy=$curUser
			HostName=$hostName}

		# create the body though it will be wholisticall ignored. It should be JSON
		$msg   = $msgProperties  | ConvertTo-Json
		$label = "$script-$labelDate"

		Write-Verbose "Message Label: `r`n $label"
		Write-Verbose "Message Body: `r`n $msg"

		# Write the messgae to the topic.
		$result = Send-BusMessageTopic  -ConnectionString $connectionString -TopicNameString $Topic `
			-MessageId 1234 -MessageBody $msg -Label $label `
			-PayloadProperties $msgProperties -RetryCount 3 #-verbose

		Write-Verbose "Send-BusMessageTopic result: `r`n $result"
	}
	catch
	{
		throw $_.Exception.Message
	}
} #process
end
{

} #end
} #function

Export-ModuleMember -function Send-DataHubTopic