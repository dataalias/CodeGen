#Create tables
Invoke-GetDDLFromModelJSON -ModelLocation "c:\users\ochowkwale\Desktop\CampusNexus\Model.JSON" -DDLLocation "C:\Users\ochowkwale\source\repos\SIS-CVue\Database\ODS\Tables\" -RefMethod "DLT" -tsnm "sis_CampusNexus"



Invoke-GetDDLFromModelJSON -ModelLocation "c:\tmp\Model.JSON" -DDLLocation "C:\tmp\" -RefMethod "DLT" -tsnm "sis_CampusNexus"


#Create stored procedures
Invoke-GetODSMergeCodeFromModelJSON -ModelLocation "c:\users\ochowkwale\Desktop\CampusNexus\Model.json" -TemplateLocation "c:\users\ochowkwale\Desktop\CampusNexus\usp_TemplateMergeProcedureV2.sql" -dl "c:\users\ochowkwale\Desktop\CampusNexus\Scripts\Tables" -pl "C:\Users\ochowkwale\source\repos\SIS-CVue\Database\ODS\Stored Procedures" -sd "BPI_DW_STAGE" -td "ODS" -tsnm "sis_CampusNexus"


#Execute the scripts

$dbServer = "DEDTEDLSQL01"

$sqlCon = New-Object System.Data.SqlClient.SqlConnection
$sqlCon.ConnectionString = "Server=$dbServer;Database=ODS;Connection Timeout=60;Integrated Security=True"

$sqlCon.Open()


$localScriptRoot = "C:\Users\ochowkwale\source\repos\SIS-CVue\Database\ODS\Tables"
$scripts = Get-ChildItem $localScriptRoot | Where-Object {$_.Extension -eq ".sql"}
 
foreach ($s in $scripts)
    {       
        $sql = Get-Content -Path $s.FullName
        $sqlCmd1 = New-Object System.Data.SqlClient.SqlCommand($sql,$sqlCon)
        $sqlCmd1.ExecuteScalar()
        $sqlCmd1.Dispose()
    }  

$localScriptRoot = "C:\Users\ochowkwale\source\repos\SIS-CVue\Database\ODS\Stored Procedures"
$scripts = Get-ChildItem $localScriptRoot | Where-Object {$_.Extension -eq ".sql"}
 
foreach ($s in $scripts)
    {       
        #$script = $s.FullName
        #Invoke-Sqlcmd -ServerInstance $dbServer -Database "ODS" -ConnectionTimeout = 60 -IntegratedSecurity = True -InputFile $script
        $sql = Get-Content -Path $s.FullName
        $sqlCmd1 = New-Object System.Data.SqlClient.SqlCommand($sql,$sqlCon)
        $sqlCmd1.ExecuteScalar()
        $sqlCmd1.Dispose()
    } 

$sqlCon.Close()
$sqlCon.Dispose()