<##############################################################################
File:		Invoke-GetODSMergeCodeFromModelJSON.ps1
Name:		Invoke-GetODSMergeCodeFromModelJSON
Purpose:


Invoke-GetODSMergeCodeFromModelJSON -ml "D:\Users\ffortunato\Documents\tmp\Model.JSON" -tl "D:\Users\ffortunato\Documents\tmp\usp_TemplateMergeProcedure.sql" -dl "D:\Users\ffortunato\Documents\tmp\DDL" -pl "D:\Users\ffortunato\Documents\tmp\procs" -sdb "GS2_STaging" -tdb "ODS" -tsnm 'loan'


ProcedureLocation: "c:\tmp:\Proc\"
SourceDatabaseName: "College_Certifications"
TargetDatabaseName: "College_Certifications"
TargetSchemaName: "dbo"

Parameters: JSON.Model
			SQL Template

Called by:	Humans
Calls:          

Errors:		

Author:		ffortunto
Date:		

##############################################################################>


#TODO
#Get this ready for pipe line.

function Invoke-GetODSMergeCodeFromModelJSON {

<#

.SYNOPSIS
This function looks at the provided directory and creates control files for
each file.

.DESCRIPTION
...

.PARAMETER directory
The directory with files that need control files generated.

.PARAMETER publicationCode
The code for the particular file being retreived.

.EXAMPLE

Invoke-GetODSMergeCodeFromModelJSON -ml "c:\tmp\Model.JSON" -tl "c:\tmp\Template\usp_TemplateMergeProcedure.sql" -dl "c:\tmp" -pl "c:\tmp\procs" -sd "ODS" -td "ODS" -tsnm "dbo"

#>


    [CmdletBinding(
        SupportsShouldProcess=$True
    )]
    param (
        [parameter(Mandatory=$true,
            Position = 0,
            HelpMessage=’The folder to look for files that do not already have a control.’
            )]
        [alias("ml")]
        [string]$ModelLocation,
		
        [parameter(Mandatory=$true,
            Position = 1,
            HelpMessage=’This is the publication code for the files being retrieved.’
            )]
        [alias("tl")]
        [string]$TemplateLocation,

        [parameter(Mandatory=$true,
            Position = 0,
            HelpMessage=’The folder to look for files that do not already have a control.’
            )]
        [alias("dl")]
        [string]$DDLLocation,
		
        [parameter(Mandatory=$true,
            Position = 1,
            HelpMessage=’This is the publication code for the files being retrieved.’
            )]
        [alias("pl")]
        [string]$ProcedureLocation,

         [parameter(Mandatory=$true,
            Position = 0,
            HelpMessage=’.’
            )]
        [alias("sdb")]
        [string]$SourceDatabaseName,
		
        [parameter(Mandatory=$true,
            Position = 1,
            HelpMessage=’.’
            )]
        [alias("tdb")]
        [string]$TargetDatabaseName,

        [parameter(Mandatory=$true,
            Position = 1,
            HelpMessage=’.’
            )]
        [alias("tsnm")]
        [string]$TargetSchemaName

	)

begin
{

}
process
{



try
{

# DECLARE
    $CrLf     = "`r`n"
    $Tab  = "t"
    $EntityCount = 0
    $AttributeCount = 0
    $SchemaName = ""
    $TableName = ""
    $ProcedureName  = ""
    $ParameterUpdate  = ""
    $ParameterList  = ""
    $ParameterInsert  = ""
    $date = date
    $version = "1.3.0.0"
    $timeZone = 'PST'
    $dateInt = 

'hi'

    # See if parameters were provided
    if (($ModelLocation -eq $null) -or ($TemplateLocation -eq $null))
    {
	    throw "No directory provided. Mandatory field cannot be null or blank."
	    return 1001
    }

    # Check to see if files exist
    if (-not (Test-Path $ModelLocation))
    {
        throw "JSON.Model file not found."
	    return 1011
    }

    if (-not (Test-Path $TemplateLocation))
    {
        throw "T-SQL Template file not found."
	    return 1012
    }

    # Load the JSON into memory
    # This config file has a whole bunch of variables used in the script.
    try
    {
	    $ModelJSONContent = Get-Content $ModelLocation -Raw | ConvertFrom-Json
    }
    catch
    {
	    throw "Unable to load Model.JSON file." + $_.Exception.Message
    }

    # Loop through entities

    $SchemaName = $ModelJSONContent.name
    $Entities = $ModelJSONContent.Entities

    foreach ($Entity in $Entities)

    {

       write-host "Table Name: $($Entity.name)"

       $TableName = "$($Entity.name)"

       $Attributes = $Entity.Attributes 


       #Where Entity = Entity Name stupid.
       #| Where {$_.Entity.name -eq $TableName})

       $AttributeCount = 1

       foreach ($Attribute in $Attributes)

       {
            #write-host "$($Attribute.name) :: $($Attribute.datatype)"

            if ($AttributeCount -eq 1)
            {
                # No leading Comma
                $ParameterSelect   = "$ParameterSelect`t"
                $ParameterList   = "$ParameterList`t"
                $ParameterInsert = "$ParameterInsert`t"
                $ParameterUpdate = "$ParameterUpdate`t"
            }
            else
            {
                #Add Leading Comma
                $ParameterSelect   = "$ParameterSelect`t,"
                $ParameterList   = "$ParameterList`t,"
                $ParameterInsert = "$ParameterInsert`t,"
                $ParameterUpdate = "$ParameterUpdate`t,"

            }
            $ParameterUpdate = "$ParameterUpdate [$($Attribute.name)] = source.[$($Attribute.name)]  $CrLf"
            $ParameterInsert = "$ParameterInsert  source.[$($Attribute.name)]  $CrLf"
            $ParameterList = "$ParameterList  [$($Attribute.name)]  $CrLf"
            
            #switch on data type!!
            
            switch ($($Attribute.datatype))
            {
                'DateTime' {$ParameterSelect = "$ParameterSelect TRY_CONVERT(datetime,SUBSTRING([$($Attribute.name)],1,23),121)  AS [$($Attribute.name)] $CrLf"}
                'Date'     {$ParameterSelect = "$ParameterSelect TRY_CONVERT(datetime,SUBSTRING([$($Attribute.name)],1,23),121)  AS [$($Attribute.name)] $CrLf"}
                'money'    {$ParameterSelect = "$ParameterSelect TRY_CONVERT($($Attribute.datatype),[$($Attribute.name)]) AS [$($Attribute.name)] $CrLf"}
                'numeric'  {$ParameterSelect = "$ParameterSelect TRY_CONVERT($($Attribute.datatype)($($Attribute.NumericPercision),$($Attribute.NumericScale)),[$($Attribute.name)]) AS [$($Attribute.name)] $CrLf"}
                default    {$ParameterSelect = "$ParameterSelect [$($Attribute.name)]  $CrLf"}
            }
            
            $AttributeCount = $AttributeCount + 1
            
        } # Attributes

        #Copy Template to Actual Procedure

        $ProcedureName = "usp_Load$($Entity.name)"
        $ProcedureFile = "$ProcedureLocation\$TargetSchemaName.usp_Load$($Entity.name).sql"

        "TemplateLocation: $TemplateLocation"
        "ProcedureName:    $ProcedureName"
        "ProcedureFile:    $ProcedureFile"

        Copy-Item -Path "$TemplateLocation" -Destination $ProcedureFile -Force


        # Replace values in the tempate with entity specific attributes

        $NewProcedureFile = Get-Content -Path $ProcedureFile
        $NewProcedureFile.replace('@@@SchemaName@@@',    $TargetSchemaName)    | Set-Content -Path $ProcedureFile

        $NewProcedureFile = Get-Content -Path $ProcedureFile
        $NewProcedureFile.replace('@@@ProcedureName@@@', $ProcedureName) | Set-Content -Path $ProcedureFile

        $NewProcedureFile = Get-Content -Path $ProcedureFile
        $NewProcedureFile.replace('@@@TargetDataBaseName@@@', $TargetDatabaseName) | Set-Content -Path $ProcedureFile

        $NewProcedureFile = Get-Content -Path $ProcedureFile
        $NewProcedureFile.replace('@@@ParameterSelect@@@', $ParameterSelect) | Set-Content -Path $ProcedureFile

        $NewProcedureFile = Get-Content -Path $ProcedureFile
        $NewProcedureFile.replace('@@@ParameterList@@@', $ParameterList) | Set-Content -Path $ProcedureFile

        $NewProcedureFile = Get-Content -Path $ProcedureFile
        $NewProcedureFile.replace('@@@ParameterInsert@@@', $ParameterInsert) | Set-Content -Path $ProcedureFile

        $NewProcedureFile = Get-Content -Path $ProcedureFile
        $NewProcedureFile.replace('@@@ParameterUpdate@@@', $ParameterUpdate) | Set-Content -Path $ProcedureFile

        $NewProcedureFile = Get-Content -Path $ProcedureFile
        $NewProcedureFile.replace('@@@TableName@@@', $TableName) | Set-Content -Path $ProcedureFile

        $NewProcedureFile = Get-Content -Path $ProcedureFile
        #FORMAT THE DATE MAN
        $NewProcedureFile.replace('@@@Date@@@', $Date) | Set-Content -Path $ProcedureFile

        $NewProcedureFile = Get-Content -Path $ProcedureFile
        $NewProcedureFile.replace('@@@Version@@@', $version) | Set-Content -Path $ProcedureFile

        $NewProcedureFile = Get-Content -Path $ProcedureFile
        $NewProcedureFile.replace('@@@SourceDatabase@@@', $sourceDatabaseName) | Set-Content -Path $ProcedureFile

        # Reset for next run in the loop
        $Attributes = $null
        $ParameterSelect = ""
        $ParameterList  = ""
        $ParameterInsert =""
        $ParameterUpdate = ""
        $ProcedureName = ""
        $TableName = ""

    } # Entities
} # try
catch
{
	throw $_.Exception.Message
	return $null
} # catch
} # process
end
{

} #end
} #function

##export-modulemember -function Invoke-GetODSMergeCodeFromModelJSON

