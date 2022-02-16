function Get-APIBusMessage {
[CmdletBinding()]
[OutPutType([Microsoft.ServiceBus.Messaging.BrokeredMessage])]
Param(
    [Microsoft.ServiceBus.Messaging.QueueClient]
    $QueueClient
    ,
    [switch] $DeQueue
    ,
    [ValidateRange(100,60000)]
    [int] $WaitTimeSpan
)
    $f = $MyInvocation.MyCommand.Name
    Write-Verbose -Message "$f - Start"

    if(-not $QueueClient)
    {
        throw "QueueClient parameter is null"
    }

    [System.TimeSpan]$waitTime = [System.TimeSpan]::FromMilliseconds($WaitTimeSpan)
    [Microsoft.ServiceBus.Messaging.BrokeredMessage]$message = $null

    if($DeQueue)
    {
        Write-Verbose -Message "$f -  Running dequeue"
        $message = $QueueClient.Receive($waitTime)
        if($message)
        {
            $message
            $message.Complete()
        }
        else
        {
            Write-Verbose "No messages available on servicebus queue '$($QueueClient.Path)'"
            break
        }
    }
    else
    {
        Write-Verbose -Message "$f -  Running peek"
        $QueueClient.Peek()
    }

    Write-Verbose -Message "$f - End"
}
