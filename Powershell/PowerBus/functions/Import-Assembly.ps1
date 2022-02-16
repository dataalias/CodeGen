function Import-Assembly {
[cmdletbinding()]
Param(
    [string[]]$files
)
    $F = $MyInvocation.MyCommand.Name
    Write-Verbose -Message "$F - START"

    foreach($file in $files)
    {
        Write-Verbose -Message "$f -  Loading assembly $file"
        Add-Type -Path $file
    }

    Write-Verbose -Message "$f - END"
}
