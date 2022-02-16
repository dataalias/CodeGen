$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Add-BusProperty" {

    Context "Output type " {
        It "Is psobject" {
            $test = (Add-BusProperty -Name "one") -is [psobject]
            $test | should be $true
        }
    }
    
    Context "Single property" {
        It "Outputs customobject with a property called one" {
            $test = Add-BusProperty -Name "one"        
            ($test.psobject.properties).name | Should Be "one"
        }
        It "Property value is teststring" {
            $test = Add-BusProperty -Name "one" -value "teststring"
            $test.one | should be "teststring"
        }
    }



    Context -Name "no param provided" {
        It "Outputs nothing/null" {
            Add-BusProperty | Should BeNullOrEmpty
        }
    }
}
