

$dbServer='.'
$db='ODS'
$dbUser='N/A'
$dbPassword='N/A'
$dbSchema='loan'
$dbTable=''
$dbColumn=''
$JSON=''
$Version='1.0.0.0'

$TableCount=1
$ColumnCount=1
$TableMaxCount=-1
$ColumnMaxCount=-1

[System.Data.DataTable] $dtTableList  = New-Object Data.datatable
[System.Data.DataTable] $dtColumnList = New-Object Data.datatable
[System.Data.DataTable] $dtKeyList    = New-Object Data.datatable

$sqlCon = New-Object System.Data.SqlClient.SqlConnection
#$sqlCon.ConnectionString = "Server=$dbServer;Database=$db;Connection Timeout=60;User=$dbUser;Password=$dbPassword"
$sqlCon.ConnectionString = "Server=$dbServer;Database=$db;Connection Timeout=60;Integrated Security=True"


$sqlTableList = "SELECT /*Top 10*/ TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$dbSchema' 
/*AND TABLE_NAME in ('ACHDetails','Ascent_Borrower')*/ 
And Table_Type <> 'VIEW'
Group By TABLE_NAME Order By TABLE_NAME"


$sqlCon.Open()
$sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter ("$sqlTableList", $sqlCon)
$sqlAdapter.Fill($dtTableList) | Out-Null
$sqlAdapter.Dispose()  



$JSONString = @"
{
    "application":"Model JSON",
	"name": "$dbSchema",
    "description": "",
    "version": "$Version",
	"modifiedtime":"",
"@

$TableMaxCount=$dtTableList.Rows.Count
"Tables to Process: $TableMaxCount"

#Loop Through Tables
foreach ($Table in $dtTableList)
{

    $dbTable=$Table.TABLE_NAME
    "Table: $TableCount of $TableMaxCount :: $dbTable" 
    if ($TableCount -eq 1)
    {
        $JSONString = $JSONString + """entities"": ["
    }
<#
    if ($TableCount -gt 1 )#-and $TableCount -lt $TableMaxCount)
    {
       "Adding a comma before entity"
        $JSONString = $JSONString + ","
    }

    $JSONString = $JSONString + 
		"        {
				""type"": ""LocalEntity"",
				""Name"": ""$dbTable"",
				""description"": """",
				""pbi:refreshPolicy"": {
					""type"": ""DeltaRefreshPolicy"",
					""location"": ""$dbTable.csv""
				},
				""Attributes"": [
"
#>


    

    $sqlColumnList = "SELECT	 ORDINAL_POSITION
		    ,TABLE_SCHEMA
		    ,TABLE_NAME
		    ,COLUMN_NAME
		    ,IS_NULLABLE
		    ,DATA_TYPE
		    ,CHARACTER_MAXIMUM_LENGTH
		    ,NUMERIC_PRECISION
		    ,NUMERIC_SCALE
		    ,DATETIME_PRECISION
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = '$dbTable'
        AND TABLE_SCHEMA = '$dbSchema'"

    $sqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter ("$sqlColumnList", $sqlCon)
    $sqlAdapter.Fill($dtColumnList) | Out-Null
    $sqlAdapter.Dispose()  
    $ColumnMaxCount=$dtColumnList.Rows.Count

    "$dbTable, Columns to Process: $ColumnMaxCount"

    foreach ($column in $dtColumnList)
    {

        $COLUMN_NAME = $column.COLUMN_NAME
        $IS_NULLABLE = $column.IS_NULLABLE
        $DATA_TYPE = $column.DATA_TYPE
        $CHARACTER_MAXIMUM_LENGTH = $column.CHARACTER_MAXIMUM_LENGTH
        $NUMERIC_PRECISION = $column.NUMERIC_PRECISION
        $NUMERIC_SCALE = $column.NUMERIC_SCALE
        $DATETIME_PRECISION = $column.DATETIME_PRECISION

        if ($ColumnCount -eq 1)
        {
            $JSONString = $JSONString + "
            {
		    ""type"": ""LocalEntity"",
		    ""Name"": ""$dbTable"",
		    ""description"": """",
		    ""pbi:refreshPolicy"": {
			    ""type"": ""DeltaRefreshPolicy"",
			    ""location"": ""$dbTable.csv""
		    },
		    ""Attributes"": [
"
        }
        if ($ColumnCount -lt $ColumnMaxCount)
        {
        	$JSONString = $JSONString + "{
						""Name"": ""$COLUMN_NAME"",
						""DataType"": ""$DATA_TYPE"",
						""IsNullable"": ""$IS_NULLABLE"",
						""CharacterMaximumLength"": ""$CHARACTER_MAXIMUM_LENGTH"",
						""NumericPercision"": ""$DATETIME_PRECISION"",
						""NumericScale"": ""$DATETIME_PRECISION""
					},
"
        }
        if ($ColumnCount -eq $ColumnMaxCount)
        {

        	$JSONString = $JSONString + "	{
						""Name"": ""$COLUMN_NAME"",
						""DataType"": ""$DATA_TYPE"",
						""IsNullable"": ""$IS_NULLABLE"",
						""CharacterMaximumLength"": ""$CHARACTER_MAXIMUM_LENGTH"",
						""NumericPercision"": ""$DATETIME_PRECISION"",
						""NumericScale"": ""$DATETIME_PRECISION""
		}
	]
}"

        }
        "$dbTable Processed Column: $ColumnCount of $ColumnMaxCount $COLUMN_NAME"
        $ColumnCount = $ColumnCount + 1
    } #foreach Column

    #Now lets get foreign keys 
    #err TODO :-P
    # $sqlForeignKey
    $ColumnCount = 1
    $dtColumnList.Clear() #Clean out colum list for next looop.

    if ($TableCount -lt $TableMaxCount)
    {
        $JSONString = $JSONString + ","
    }
    if ($TableCount -eq $TableMaxCount)
    {
        $JSONString = $JSONString + "]"
    }



    $TableCount = $TableCount + 1
} #foreach Table

$JSONString = $JSONString + "}"

$JSONString | Out-File -FilePath "c:\tmp\Model.JSON"

$sqlCon.Dispose()
