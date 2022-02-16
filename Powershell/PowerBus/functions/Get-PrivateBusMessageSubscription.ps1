function Get-PrivateBusMessageSubscription
{
[CmdletBinding()]
[OutPutType([Microsoft.ServiceBus.Messaging.BrokeredMessage])]
Param(
    [switch] $DeQueue
    ,
    [string] $ConnectionString
    ,
    [string] $SubscriptionNameString
    ,
	[String] $TopicPath
	,
    [ValidateRange(100,60000)]
    [int] $WaitTimeSpan = 500
)
    $f = $MyInvocation.MyCommand.Name
    Write-Verbose -Message "$f - Start"
    Write-Verbose -Message "$f - ConnectionString       = $ConnectionString"
	Write-Verbose -Message "$f - TopicPath              = $TopicPath"
    Write-Verbose -Message "$f - SubscriptionNameString = $SubscriptionNameString"

    if(-not $ConnectionString)
    {
        throw "ConnectionString parameter is empty/null"
    }

    if(-not $SubscriptionNameString)
    {
        throw "SubscriptionNameString parameter is empty/null"
    }
	if(-not $TopicPath)
    {
        throw "SubscriptionNameString parameter is empty/null"
    }

    [Microsoft.ServiceBus.Messaging.SubscriptionClient]$SubscriptionClient = `
		[Microsoft.ServiceBus.Messaging.SubscriptionClient]::CreateFromConnectionString($ConnectionString, $TopicPath,  $SubscriptionNameString)
    [Microsoft.ServiceBus.Messaging.BrokeredMessage] $Message = $null

	Write-Verbose -Message "$f - SubscriptionClient     = '$($SubscriptionClient.Path)'"

    if($DeQueue)
    {
        Write-Verbose -Message "$f -  Running dequeue"
        $Message = Get-APIBusMessageSubscription -SubscriptionClient $SubscriptionClient -DeQueue -WaitTimeSpan $WaitTimeSpan
    }
    else
    {
        Write-Verbose -Message "$f -  Running peek"
        $Message = Get-APIBusMessageSubscription -SubscriptionClient $SubscriptionClient
    }
    
    Write-Verbose -Message "$f - End"

    $Message
}
