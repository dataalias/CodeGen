[string[]] $Script:Assemblies = @()

#$Script:Assemblies += "$psScriptRoot\bin\Microsoft.ServiceBus.dll"
#$Script:Assemblies += "$psScriptRoot\bin\Microsoft.WindowsAzure.Configuration.dll"
$Script:Assemblies += "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.ServiceBus.dll"
$Script:Assemblies += "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.WindowsAzure.Configuration.dll"


$script:PSDefaultParameterValues
$functions = "$psScriptRoot\Functions\*.ps1" | Resolve-Path | Where-Object { -not ($_.ProviderPath.Contains(".Tests.")) }

foreach($function in $functions)
{
    . $function.ProviderPath
}

Write-Verbose -Message "Checking dependencies"
Assert-PreReqs -files $Script:Assemblies

Write-Verbose -Message "Loading assemblies"
Import-Assembly -files $Script:Assemblies

function Get-BusRequiredAssembly
{
[cmdletbinding()]
Param()
    $Script:Assemblies
}

function Get-BusDefaults
{
<#
.Synopsis
   Outputs the current defaults
.DESCRIPTION
   Outputs the default parameters for ConnectionString and QueueNameString
.EXAMPLE
   Get-BusDefaults
.NOTES
   KEYWORDS: Azure ServiceBus powershell module
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
#>
[cmdletbinding()]
Param()

    $Script:PSDefaultParameterValues
}

function Set-BusDefaults
{
<#
.Synopsis
   Sets default parameters for the cmdlets in the module
.DESCRIPTION
   Creates default parameters for ConnectionString and QueueNameString
.EXAMPLE
   Set-BusDefaults -QueueName "testqueue" -BusConnectionstring "Endpoint=sb://yourqueue.servicebus.windows.net/;SharedAccessKeyName=rootKey;SharedAccessKey=eLOdFasdaKJoiOIJhiuhO98hoihjLKH"
.NOTES
   KEYWORDS: Azure ServiceBus powershell module
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
#>
[cmdletbinding()]
Param(
    [string]$BusConnectionstring = ""
    ,
    [string]$QueueName = ""
)
    
    if($script:PSDefaultParameterValues.Count -eq 0)
    {
        Write-Verbose "adding to list"
        $script:PSDefaultParameterValues.Add("*-*BusMessage*:QueueNameString",$QueueName)
        $script:PSDefaultParameterValues.Add("*-*BusMessage*:ConnectionString",$BusConnectionstring)
    }
    else
    {
        Write-Verbose "setting value"
        $script:PSDefaultParameterValues["*-*BusMessage*:ConnectionString"] = $BusConnectionstring
        $script:PSDefaultParameterValues["*-*BusMessage*:QueueNameString"] = $QueueName
    }
}

function Get-BusMessage
{
<#
.Synopsis
   Get a message from an Azure ServiceBus queue
.DESCRIPTION
   Supports peek(default) and deque mode.
.EXAMPLE
   Get-BusMessage

   Outputs the first available message in the queue (peek-mode)
.EXAMPLE
   Get-BusMessage -WaitTimeSpan 500 -DeQueue

   Outputs the first available message in the queue and dequeues it, waiting 500 milliseconds for the transaction to complete

.NOTES
   KEYWORDS: Azure ServiceBus powershell module
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
#>
[CmdletBinding()]
[OutPutType([Microsoft.ServiceBus.Messaging.BrokeredMessage])]
Param(
    [switch] $DeQueue
    ,    
    [string] $ConnectionString
    ,
    [string] $QueueNameString
    ,
    [ValidateRange(100,60000)]
    [int] $WaitTimeSpan
)
    
    Get-PrivateBusMessage @PSBoundParameters

}

function Get-BusMessageSubscription
{
<#
.Synopsis
   Get a message from an Azure ServiceBus subscription
.DESCRIPTION
   Supports peek(default) and deque mode.
.EXAMPLE
   Get-BusMessageTopic

   Outputs the first available message in the queue (peek-mode)
.EXAMPLE
   Get-BusMessageTopic -WaitTimeSpan 500 -DeQueue

   Outputs the first available message in the queue and dequeues it, waiting 500 milliseconds for the transaction to complete

.NOTES
   KEYWORDS: Azure ServiceBus powershell module
   AUTHOR: ffortunato 
#>
[CmdletBinding()]
[OutPutType([Microsoft.ServiceBus.Messaging.BrokeredMessage])]
Param(
    [switch] $DeQueue
    ,    
    [string] $ConnectionString
    ,
    [string] $SubscriptionNameString
    ,
	[string] $TopicPath
	,
    [ValidateRange(100,60000)]
    [int] $WaitTimeSpan
)
    
    Get-PrivateBusMessageSubscription @PSBoundParameters

}

function Send-BusMessage
{
<#
.Synopsis
   Sends a message to an Azure ServiceBus queue
.DESCRIPTION
   Returns a boolean value indicating true if successful or false otherwise.
.EXAMPLE
   Send-BusMessage -label "this is my label"

   Sends a message to the queue and setting the message label to "this is my label"
.EXAMPLE
   Send-BusMessage -label "this is my label" -MessageBody "this is the body"

   Sends a message to the queue with the message label set to "this is my label" and body set to "this is the body"

.NOTES
   KEYWORDS: Azure ServiceBus powershell module
   AUTHOR: Tore Groneng tore@firstpoint.no @toregroneng tore.groneng@gmail.com
#>
[CmdletBinding()]
[OutPutType([bool])]
Param(
    [string] $MessageBody
    ,
    [string] $Label
    ,
    [PSCustomObject] $PayloadProperties
    ,
    [int] $MessageID
    ,
    [int] $RetryCount
    ,
    [string] $ConnectionString
    ,
    [string] $QueueNameString
)
    Send-PrivateBusMessage @PSBoundParameters
}

function Send-BusMessageTopic
{
<#
.Synopsis
   Sends a message to an Azure ServiceBus Topic
.DESCRIPTION
   Returns a boolean value indicating true if successful or false otherwise.
.EXAMPLE
   Send-BusMessageTopic -label "this is my label"

   Sends a message to the queue and setting the message label to "this is my label"
.EXAMPLE
   Send-BusMessageTopic -label "this is my label" -MessageBody "this is the body"

   Sends a message to the queue with the message label set to "this is my label" and body set to "this is the body"

.NOTES
   KEYWORDS: Azure ServiceBus powershell module
   AUTHOR: ffortunato
#>
[CmdletBinding()]
[OutPutType([bool])]
Param(
    [string] $MessageBody
    ,
    [string] $Label
    ,
    [PSCustomObject] $PayloadProperties
    ,
    [int] $MessageID
    ,
    [int] $RetryCount
    ,
    [string] $ConnectionString
    ,
    [string] $TopicNameString
)
    Send-PrivateBusMessageTopic @PSBoundParameters
}

function Get-PowerBusFunctions {

process
{
	# '*****Get-Module*****'
	# Get-Module dmutils -ListAvailable | % { $_.ExportedCommands.Values }
	
	'*****Get-Commands*****'
	Get-Command -Module PowerBus
} # process
} # function

Export-ModuleMember Get-BusMessage, Send-BusMessage, Get-BusDefaults, Set-BusDefaults, Get-BusRequiredAssembly, Get-PowerBusFunctions, `
Send-BusMessageTopic, Get-BusMessageSubscription