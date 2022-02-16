$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Send-APIBusMessage" {
    Context "Parameter validation" {
        It "QueueClient null should throw" {
            { Send-APIBusMessage -Message (Get-BusBrokeredMessage) } | Should throw
        }

        It "Message null should throw" {
            $client = [Microsoft.ServiceBus.Messaging.QueueClient]::CreateFromConnectionString("Endpoint=sb://spvtest.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=mbp72DG/CGwZSBp88e4uJDee6We6dVu2ZKM1zxkK921=","aa")
            { Send-APIBusMessage -QueueClient $client } | Should throw
        }

        It "All null should trow" {
            { Send-APIBusMessage } | Should throw
        }
    }    
}
