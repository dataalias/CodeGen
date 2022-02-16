function Send-APIBusMessageTopic {
[CmdletBinding()]
[OutPutType([bool])]
Param(
    [Microsoft.ServiceBus.Messaging.TopicClient]
    $TopicClient
    ,
    [Microsoft.ServiceBus.Messaging.BrokeredMessage]
    $Message
)
    $f = $MyInvocation.MyCommand.Name
    Write-Verbose -Message "$f - Start"

    if(-not $TopicClient)
    {
        throw "TopicClient parameter is empty"
    }

    if(-not $Message)
    {
        throw "Message parameter is empty"
    }
    [bool] $ReturnValue = $false   

    try
    {
        Write-Verbose -Message "$f -  Trying to send"
        $TopicClient.Send($Message)
        Write-Verbose -Message "$f -  Busmessage sent"
        $ReturnValue = $true
    }
    catch [Microsoft.ServiceBus.Messaging.MessagingException]
    {
        Write-Verbose -Message "$f -  MessagingException"
        if(-not $_.Exception.IsTransient)
        {
            Write-Error -Exception $_.Exception -Message $_.Exception.Message
            throw "Error sending message to Azure for Queue $QueueName"
        }
        else
        {
            [string]$Msg = "$f -  Error while sending (IsTransient). Please retry" 
            Write-Error -Message $Msg -Exception $_.Exception       
        }
    }
    catch
    {
        Write-Verbose -Message "$f -  General exception"
        Write-Error -Exception $_.Exception -Message $_.Exception.Message
    }
    Finally
    {
        if($TopicClient)
        {
            $TopicClient.Close()
        }
        Write-Verbose -Message "$f - End"
    }    
    $ReturnValue
}
