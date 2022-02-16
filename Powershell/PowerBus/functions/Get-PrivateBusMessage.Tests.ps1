$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

function Get-APIBusMessage {}

Describe "Get-PrivateBusMessage" {
    Context "Parameter validation" {
        It "ConnectionString null should throw" {
            { Get-PrivateBusMessage -QueueNameString "dummy" } | Should throw
        }

        It "QueueNameString null should throw" {
            { Get-PrivateBusMessage -ConnectionString "something" } | Should throw
        }

        It "WaitTimeSpan less than 100 should throw" {
            { Get-PrivateBusMessage -WaitTimeSpan 90 } | Should throw
        }

        It "WaitTimeSpan null should throw" {
            { Get-PrivateBusMessage } | Should throw
        }

        It "All null should throw" {
            { Get-PrivateBusMessage } | Should throw
        }
    }

    $param = @{
        ConnectionString = "Endpoint=sb://spvtest.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=mbp72DG/CGwZSBp88e4uJDee6We6dVu2ZKM1zxkK921="
        QueueNameString = "dummy"           
    }

    Context "Mock Get-APIBusMessage" {
        Mock Get-APIBusMessage { $null }
            It "No message received should not throw" {                           
                { Get-PrivateBusMessage @param } | Should not throw
            }
            
            It "No message received should be empty/null" {                           
                Get-PrivateBusMessage @param | Should BeNullOrEmpty
            }

        Mock Get-APIBusMessage { [Microsoft.ServiceBus.Messaging.BrokeredMessage] $Message = New-Object -TypeName Microsoft.ServiceBus.Messaging.BrokeredMessage ; $Message }
            It "Message received should be of type BrokeredMessage" {
                                        
                (Get-PrivateBusMessage @param) -is [Microsoft.ServiceBus.Messaging.BrokeredMessage] | Should be $true
            }

            It "Message received should not throw " {                         
                { Get-PrivateBusMessage @param } | Should not throw
            }
    }
   
}
