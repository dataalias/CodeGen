function Add-BusProperty {
[cmdletbinding()]
Param(
    [string] $Name
    ,
    [string] $value
)
    $f = $MyInvocation.MyCommand.Name
    Write-Verbose -Message "$f - START"

    if(-not $name)
    {
        #Write-Error "fail"
        return @()
    }
    
    if(-not $Script:Properties)
    {
        Write-Verbose -Message "$F -  Creating new object"
        $Properties = New-Object pscustomobject
    }
    
    Write-Verbose -Message "$f -  Adding properties"
    [int]$i = 0
    foreach ($Prop in $Name)
    {
        Write-Verbose -Message "$f -  Adding prop $prop with value $value"
        $Properties | Add-Member -MemberType NoteProperty -Name $Prop -Value $value -Force  
    }
    Write-Verbose -Message "$f - END"
    $Properties
}

