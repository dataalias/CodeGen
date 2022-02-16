function Assert-PreReqs {
    [cmdletbinding()]
    [OutPutType([bool])]
    Param(
        [string[]]$files
    )
    $F = $MyInvocation.MyCommand.Name
    Write-Verbose "$PSScriptRoot"
    Write-Verbose -Message "$F - START"
    
    #no files provided return false
    if(-not $files)
    {
        Write-Verbose "$f - No files provided returning false"
        Write-Verbose -Message "$f - END"
        return $false
    }
    
    #if any file is missing return false
    foreach($file in $files)
    {
        if (Test-Path -Path $file)
        {
            Write-Verbose -Message "$f - File '$file' exists"
        }
        else
        {
            Write-Verbose -Message "$f - File '$file' was not found returning false"
            Write-Verbose -Message "$f - END"
            return $false
        }
        
    }
    
    #all files were found, return true
    Write-Verbose -Message "$f - All files found, returning true"
    Write-Verbose -Message "$f - END"
    return $true
    
}
