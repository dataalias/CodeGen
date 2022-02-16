<##############################################################################
File:		Invoke-GetDDLFromModelJSON.ps1
Name:		Invoke-GetDDLFromModelJSON
Purpose:


Parameters: JSON.Model
			Directory to dump ddl to

Called by:	Humans
Calls:          

Errors:		

Author:		ffortunto
Date:		

##############################################################################>


#TODO
#Get this ready for pipe line.

function Invoke-GetDDLFromModelJSON {

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

Invoke-GetDDLFromModelJSON -ModelLocation "c:\tmp\Model.JSON" -DDLLocation "c:\tmp\"

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
        [alias("dl")]
        [string]$DDLLocation,

        [parameter(Mandatory=$true,
            Position = 0,
            HelpMessage=’The folder to look for files that do not already have a control.’
            )]
        [alias("MethodCode")]
        [string]$RefMethod,

        [parameter(Mandatory=$true,
            Position = 0,
            HelpMessage=’The folder to look for files that do not already have a control.’
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
    $Tab  = "`t"
    $EntityCount = 0
    $AttributeCount = 0
    $SourceSchemaName = ""
    $TableName = ""
    $ProcedureName  = ""
    $ParameterUpdate  = ""
    $ParameterList  = ""
    $ParameterInsert  = ""
    $date = date
    $version = "1.3.0.0"
    $timeZone = 'PST'
    $FileContent = ''
    $curUser  = whoami

    # See if parameters were provided
    if (($ModelLocation -eq $null) -or ($DDLLocation -eq $null))
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

    if (-not (Test-Path $DDLLocation))
    {
        throw "DDL FOlder not found."
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

    $SourceSchemaName = $ModelJSONContent.name
    $Entities = $ModelJSONContent.Entities

    foreach ($Entity in $Entities)

    {

       write-host "Table Name: $($Entity.name)"

       $TableName = "$($Entity.name)"

$FileContent = @"
/******************************************************************************
file:           $TableName.sql
name:           $TableName

purpose:        

author:         $curUser (Auto Generated)
date:           $date
******************************************************************************/
$CrLf
"@


       $FileContent = "$FileContent CREATE TABLE $TargetSchemaName.$TableName ($CrLf $Tab DW_$TableName" + "ID bigint IDENTITY(1,1) PRIMARY KEY CLUSTERED  NOT NULL $CrLf"

       $Attributes = $Entity.Attributes 

       $AttributeCount = 1

       foreach ($Attribute in $Attributes)

       {
            #write-host "$($Attribute.name) :: $($Attribute.datatype)"

#            if ($AttributeCount -eq 1)
#            {
#                # No leading Comma
#                $FileContent   = "$FileContent $CrLf $Tab "

#            }
#            else
#            {
#                #Add Leading Comma
                $FileContent   = "$FileContent`t,"
#            }
            
            #Character Length
            switch ($($Attribute.CharacterMaximumLength))
            {
                '-1'	{$Attribute.CharacterMaximumLength = "max"}	
                default {$Attribute.CharacterMaximumLength = $Attribute.CharacterMaximumLength}
            }

            # Attribute Name
            $FileContent = "$FileContent[$($Attribute.name)]`t"
            
            #Data Type
            switch ($($Attribute.datatype))
            {
                'bigint'	{$FileContent = "$FileContent $($Attribute.datatype)`t"}		
                'binary'	{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'bit'		{$FileContent = "$FileContent $($Attribute.datatype)`t"}		
                'char'		{$FileContent = "$FileContent $($Attribute.datatype)($($Attribute.CharacterMaximumLength))`t"}
                'date'		{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'datetime'	{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'datetime2'	{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'datetimeoffset'{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'decimal'	{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'float'		{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'hierarchyid'{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'image'		{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'int'		{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'money'		{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'nchar'		{$FileContent = "$FileContent $($Attribute.datatype)($($Attribute.CharacterMaximumLength))`t"}	
                'ntext'		{$FileContent = "$FileContent $($Attribute.datatype)`t"}	
                'nvarchar'	{$FileContent = "$FileContent $($Attribute.datatype)($($Attribute.CharacterMaximumLength))`t"}		
                'numeric'	{$FileContent = "$FileContent $($Attribute.datatype)($($Attribute.NumericPercision),$($Attribute.NumericScale))`t"}		
                'real'		{$FileContent = "$FileContent $($Attribute.datatype)`t"}		
                'smalldatetime' {$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'smallint'	{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'smallmoney'{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'text'		{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'time'		{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'timestamp'	{$FileContent = "$FileContent varchar(100)`t"}
                'tinyint'	{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'uniqueidentifier' {$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'varbinary'	{$FileContent = "$FileContent $($Attribute.datatype)`t"}
                'varchar'	{$FileContent = "$FileContent $($Attribute.datatype)($($Attribute.CharacterMaximumLength))`t"}	                
                default {$FileContent = "$FileContent nvarchar(max)`t"}
            }

            # IS Nullable
            switch ($($Attribute.IsNullable))
            {
                'YES' {$FileContent = "$FileContent NULL"}
                'NO'  {$FileContent = "$FileContent NOT NULL"}
                default {$FileContent = "$FileContent NULL"}
            }

            $FileContent = "$FileContent$CrLf"
            $AttributeCount = $AttributeCount + 1
            
        } # Attributes

#Close out the create statement

        #$Method = 'TXN'

        switch ($RefMethod)
        {
            'TXN'{$FileContent = "$FileContent`t,[IssueId] [int] NOT NULL$CrLf)"}
            'DLT'{$FileContent = "$FileContent`t,[IssueId] [int] NOT NULL
    ,[StartDtm_UTC] datetime2(7) GENERATED ALWAYS AS ROW START NOT NULL
    ,[EndDtm_UTC] datetime2(7) GENERATED ALWAYS AS ROW END NOT NULL
    ,PERIOD FOR SYSTEM_TIME (StartDtm_UTC, EndDtm_UTC)  
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = $TargetSchemaName.$($TableName)History));"}
            default {'Hi2'}
        }

        
        #Copy Template to Actual sql file
        $DDLName = "$($Entity.name)"
        $DDLFile = "$DDLLocation$TargetSchemaName.$($Entity.name).sql"

        "ProcedureName: $DDLName"
        "ProcedureFile: $DDLFile"

        $FileContent | Out-File -FilePath $DDLFile

        #Copy-Item -Path "$TemplateLocation" -Destination $DDLFile -Force


        # Replace values in the tempate with entity specific attributes

#WRITE VARIABLE TO FILE

        # Reset for next run in the loop
        $Attributes = $null
        $ParameterList  = ""
        $ParameterInsert =""
        $ParameterUpdate = ""
        $ProcedureName = ""
        $TableName = ""
        $FileContent = ""

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

#export-modulemember -function Invoke-GetDDLFromModelJSON

