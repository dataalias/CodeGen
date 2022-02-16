function Get-PrivateBusMessage 
{
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
    [int] $WaitTimeSpan = 500
)
    $f = $MyInvocation.MyCommand.Name
    Write-Verbose -Message "$f - Start"

    Write-Verbose -Message "$f -  ConnectionString=$ConnectionString"
    Write-Verbose -Message "$f -  QueueNameString =$QueueNameString"

    if(-not $ConnectionString)
    {
        throw "ConnectionString parameter is empty/null"
    }

    if(-not $QueueNameString)
    {
        throw "QueueNameString parameter is empty/null"
    }

    [Microsoft.ServiceBus.Messaging.QueueClient]$QueueClient = [Microsoft.ServiceBus.Messaging.QueueClient]::CreateFromConnectionString($ConnectionString, $QueueNameString)

    [Microsoft.ServiceBus.Messaging.BrokeredMessage] $Message = $null

    if($DeQueue)
    {
        Write-Verbose -Message "$f -  Running dequeue"
        $Message = Get-APIBusMessage -QueueClient $QueueClient -DeQueue -WaitTimeSpan $WaitTimeSpan
    }
    else
    {
        Write-Verbose -Message "$f -  Running peek"
        $Message = Get-APIBusMessage -QueueClient $QueueClient
    }
    
    Write-Verbose -Message "$f - End"

    $Message
}
