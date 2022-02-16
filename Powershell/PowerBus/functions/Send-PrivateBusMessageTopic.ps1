function Send-PrivateBusMessageTopic
{
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
    $f = $MyInvocation.MyCommand.Name
    Write-Verbose -Message "$f - Start"
    Write-Verbose -Message "$f -  Verify default parameters"
    Write-Verbose -Message "$f -  ConnectionString:$ConnectionString"
    Write-Verbose -Message "$f -  TopicNameString :$TopicNameString"
	Write-Verbose -Message "$f -  Properties : $PayloadProperties"
    
    if(-not $ConnectionString)
    {
        throw "ConnectionString parameter is emtpy"
    }

    if(-not $TopicNameString)
    {
        throw "TopicNameString parameter is emtpy"
    }

    [bool] $SendSuccess = $False

    try
    {
        Write-Verbose -Message "$f -  Creating client"
        [Microsoft.ServiceBus.Messaging.TopicClient]$TopicClient = [Microsoft.ServiceBus.Messaging.TopicClient]::CreateFromConnectionString($ConnectionString, $TopicNameString)

        [Microsoft.ServiceBus.Messaging.BrokeredMessage] $Message = New-Object -TypeName Microsoft.ServiceBus.Messaging.BrokeredMessage -ArgumentList @(,"$MessageBody")
        $Message.Label = "$Label"
     
        if($MessageID)
        {
            $message.MessageId = $MessageID
        }

        Write-Verbose -Message "$f -  Checking for payload properties"
        if($PayloadProperties)
        {
			foreach($prop in $PayloadProperties.GetEnumerator())
            {
				$msg = "$f -  Adding property " + $prop.key + " with value " + $prop.value
                Write-Verbose -Message $msg 
                $Message.Properties.Add($prop.Key,$prop.Value)
            }
        }
        Write-Verbose -Message "$f -  Calling Send-APIBusMessage to send message"
        $SendSuccess = Send-APIBusMessageTopic -TopicClient $TopicClient -Message $Message
    }
    catch
    {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message        
    }
    Finally
    {
        If($TopicClient)
        {
            $TopicClient.Close()
        }
        Write-Verbose -Message "$f - End"
    }
    
    $SendSuccess
}
