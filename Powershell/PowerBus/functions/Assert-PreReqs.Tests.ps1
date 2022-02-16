$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Assert-PreReqs" {
    Context "Parameter validation" {
        $valid = $script:MyInvocation.MyCommand.Path
        
        $invalid = $valid + "1"
        if (Test-Path $invalid) { throw "The path '$invalid' should not exist but it exists"}
        
    
        It "Valid path provided should be true" {
            Assert-PreReqs -files $valid | Should Be $true
        }
        
        It "Multiple valid paths provided should be true" {
            Assert-PreReqs -files $valid, $valid | Should Be $true
        }

        It "Invalid path provided should be false" {
            Assert-PreReqs -files $invalid | Should Be $false
        }
        
        It "Multiple invalid paths provided should be false" {
            Assert-PreReqs -files $invalid, $invalid | Should Be $false
        }
        
        It "Mix of valid and invalid paths should be false" {
            Assert-PreReqs -files $valid, $valid, $invalid | Should Be $false
        }

        It "Valid path provided should not throw" {
            { Assert-PreReqs -files $valid } | Should not throw
        }

        It "No parameters should be false" {
            Assert-PreReqs | Should Be $false
        }
    }
}
