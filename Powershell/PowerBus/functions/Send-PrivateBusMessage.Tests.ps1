$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

function Send-APIBusMessage {}
$PSBoundParameters.clear()
Describe "Send-PrivateBusMessage" {
    Context "Parameter validation" {
        It "ConnectionString null should throw" {
            { Send-PrivateBusMessage -QueueNameString "dummy" } | Should throw
        }

        It "QueueNameString null should throw" {
            { Send-PrivateBusMessage -ConnectionString "something" } | Should throw
        }

        It "All null should trow" {
            { Send-PrivateBusMessage } | Should throw
        }
    }
    $param = @{
        ConnectionString = "Endpoint=sb://spvtest.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=mbp72DG/CGwZSBp88e4uJDee6We6dVu2ZKM1zxkK921="
        QueueNameString = "dummy"           
    }

    Context "Mock Send-APIBusMessage" {
        Mock Send-APIBusMessage { $false }       
            It "Failed to send should be false" {                           
                Send-PrivateBusMessage @param | Should be $false
            }

            It "Failed to send should not throw " {                           
                { Send-PrivateBusMessage @param -Label "test" } | Should not throw
            }

        Mock Send-APIBusMessage { $true }
            It "Send success should be true" {                           
                Send-PrivateBusMessage @param -Label "test" | Should be $true
            }

            It "Send success should not throw " {                           
                { Send-PrivateBusMessage @param -Label "test" } | Should not throw
            }
    }
}
