function Get-APIBusMessageSubscription {
[CmdletBinding()]
[OutPutType([Microsoft.ServiceBus.Messaging.BrokeredMessage])]
Param(
    [Microsoft.ServiceBus.Messaging.SubscriptionClient]
    $SubscriptionClient
    ,
    [switch] $DeQueue
    ,
    [ValidateRange(100,60000)]
    [int] $WaitTimeSpan
)
    $f = $MyInvocation.MyCommand.Name
    Write-Verbose -Message "$f - Start"
	Write-Verbose -Message "$f - Subscription: '$($SubscriptionClient.Path)'"

    if(-not $SubscriptionClient)
    {
        throw "SubscriptionClient parameter is null"
    }

    [System.TimeSpan]$waitTime = [System.TimeSpan]::FromMilliseconds($WaitTimeSpan)
    [Microsoft.ServiceBus.Messaging.BrokeredMessage]$message = $null
try{
    if($DeQueue)
    {
        Write-Verbose -Message "$f -  Running dequeue"
        $message = $SubscriptionClient.Receive($waitTime)
        if($message)
        {
            $message
            $message.Complete()
        }
        else
        {
            Write-Verbose "No messages available on servicebus queue '$($SubscriptionClient.Path)'"
            break
        }
    }
    else
    {
        Write-Verbose -Message "$f -  Running peek"
        $SubscriptionClient.Peek()
    }
}
	catch
	{   Write-Error 'wacka wacka'
		throw $_.ExceptionMessage
	}
    Write-Verbose -Message "$f - End"
}
