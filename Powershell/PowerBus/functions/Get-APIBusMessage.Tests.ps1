$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Get-APIBusMessage" {
    Context "Parameter validation" {
        It "QueueClient null should throw" {
            { Get-APIBusMessage -DeQueue -WaitTimeSpan 100 } | Should throw
        }

        It "WaitTimeSpan less than 100 should throw" {
            { Get-APIBusMessage -DeQueue -WaitTimeSpan 90 } | Should throw
        }

        It "WaitTimeSpan null should throw" {
            { Get-APIBusMessage -DeQueue } | Should throw
        }

        It "All null should trow" {
            { Get-APIBusMessage } | Should throw
        }
    }
}
