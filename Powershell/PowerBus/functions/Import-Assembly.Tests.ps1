$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Import-Assembly" {
    Context "Parameter validation" {
        It "No parameters provided should BeNullOrEmpty" {
            Import-Assembly | Should BeNullOrEmpty
        }

        It "No parameters provided should BeNullOrEmpty" {
            { Import-Assembly } | Should Not Throw
        }

        It "Not present file should throw" {
            { Import-Assembly -files ".\balle.dll" } | Should Throw
        }
    }
}
