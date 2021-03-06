USE [SQLAdmin]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetJSONDefinitionForTable]    Script Date: 2/12/2021 1:48:10 PM ******/
CREATE procedure [dbo].[usp_GetJSONDefinitionForTable](
		 @pTableName		nvarchar(255)
		,@pSchemaName		nvarchar(255)
		,@pJSONString		nvarchar(max) output
		,@pVerbose			bit = 0
)

as
/*****************************************************************************
File:           usp_GetJSONDefinitionForTable.sql
Name:           usp_GetJSONDefinitionForTable
Purpose:        Take the list of objects and .

declare @JSONString nvarchar(max) = ''
exec dbo.usp_GetJSONDefinitionForTable 
	 @pTableName = 'FaFAFSA09'
	,@pSchemaName = 'dbo'
	,@pJSONString = @JSONString output
print '****************************** Final Output ******************************'
print @JSONString
	

 Parameters:    



 Called by:      Application
 Calls:          

 Author:         ffortunato
 Date:           20210129

*******************************************************************************
       CHANGE HISTORY
*******************************************************************************
Date		Author         Description
--------	-------------	---------------------------------------------------
20210129	ffortunato		Initial Iteration

******************************************************************************/
begin

declare	 @ParameterString			nvarchar(4000)
		,@Max						int
		,@Cnt						int
		,@parameterpassedchar		nvarchar(4000)
		,@LiteralCRLF				nvarchar(20)	= 'char(13) + char(10)'
		,@CRLF						nvarchar(20)	=  char(13) + char(10) -- CR + LF
		,@CurrentParameterName		varchar(255)
		,@CurrentParameterType		varchar(255)
		,@CurrentParameterOutput	int 
		,@CurrentParameterSchema    nvarchar(200)
		,@Tab						varchar(5)	= '    ' -- char(9)
		,@2Tab						varchar(6)	= '        ' -- char(9) + char(9)
		,@3Tab						varchar(6)	= '            ' -- char(9) + char(9) + char(9)
		,@ParmLength				int = -1
		,@TabLenght					int = 4
		,@MaxParmLength				int = -1
		,@TargetTabLength			int = -1
		,@TabsToAddCount			int = -1
		,@TabsToAddChar				varchar(20)
		,@JSONString				nvarchar(max)	= ''
		,@OrdinalPosition			int
		,@TableSchema				nvarchar(255)
		,@TableName					nvarchar(255)
		,@ColumnName				nvarchar(255)
		,@IsNullable				nvarchar(255)
		,@DataType					nvarchar(255)
		,@CharacterMaximumLength	int
		,@NumericPrecision			int
		,@NumericScale				int
		,@DataTimePercision			int
		,@JSONDataType				nvarchar(50)

declare	@ColumnList table 
(
		 ColumnListId				int identity(1,1)
		,OrdinalPosition			int
		,TableSchema				nvarchar(255)
		,TableName					nvarchar(255)
		,ColumnName					nvarchar(255)
		,IsNullable					nvarchar(255)
		,DataType					nvarchar(255)
		,CharacterMaximumLength		int
		,NumericPrecision			int
		,NumericScale				int
		,DataTimePercision			int
)

insert into @ColumnList (
		OrdinalPosition
		,TableSchema
		,TableName
		,ColumnName
		,IsNullable
		,DataType
		,CharacterMaximumLength
		,NumericPrecision
		,NumericScale		
		,DataTimePercision
)
SELECT	 ORDINAL_POSITION
		,TABLE_SCHEMA
		,TABLE_NAME
		,COLUMN_NAME
		,IS_NULLABLE
		,DATA_TYPE
		,CHARACTER_MAXIMUM_LENGTH
		,NUMERIC_PRECISION
		,NUMERIC_SCALE
		,DATETIME_PRECISION
FROM c2000.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @pTableName
AND TABLE_SCHEMA = @pSchemaName

-- select  * from @ColumnList

if exists (select top 1 1 from @ColumnList)
	begin
		select	 @Cnt			= 1
				,@Max			= (select max(ColumnListId) from @ColumnList)
	end
else
	begin
		select @JSONString = ''
		return
	end

while  @Cnt <= @Max and @Cnt <> -1
begin

	select	 @OrdinalPosition	=	OrdinalPosition
			,@TableSchema		=	TableSchema
			,@TableName			=	TableName
			,@ColumnName		=	ColumnName
			,@IsNullable		=	IsNullable
			,@DataType			=	DataType
			,@CharacterMaximumLength	=	CharacterMaximumLength
			,@NumericPrecision	=	NumericPrecision
			,@NumericScale		=	NumericScale
			,@DataTimePercision	=	DataTimePercision
	from	 @ColumnList
	where	 ColumnListId = @Cnt

--	select @ColumnName

	select	 @JSONDataType  = @DataType
	/*
	select	 @JSONDataType = CASE @DataType
		when 'bigint' then 'Int64'
		when 'binary' then 'Binary'
		when 'bit' then 'Boolean'
		when 'char' then 'Char'
		when 'date' then 'Date'
		when 'datetime' then 'DateTime'
		when 'datetime2' then  'DateTime'
		when 'datetimeoffset' then  'DateTimeOffset'
		when 'decimal' then 'Decimal'
		when 'float' then 'Float'
		when 'hierarchyid' then 'Unknown'
		when 'image' then 'Binary'
		when 'int' then 'Int32'
		when 'money' then 'Decimal'
		when 'nchar' then 'string'
		when 'ntext' then 'string'
		when 'numeric' then 'deciaml'
		when 'nvarchar' then 'string'
		when 'real' then 'Double'
		when 'smalldatetime' then 'DataTime'
		when 'smallint' then 'Int32'
		when 'smallmoney' then 'Decimal'
		when 'text' then 'string'
		when 'time' then 'Time'
		when 'timestamp' then 'DateTimeOffset'
		when 'tinyint' then 'int32'
		when 'uniqueidentifier' then 'Unknown'
		when 'varbinary' then 'Binary'
		when 'varchar' then 'String'
		else 'string' end
*/
	if @Cnt = 1 
	begin
		select @JSONString = 
		'        {
				"$type": "LocalEntity",
				"Name": "' + @TableName + '",
				"description": "",
				"pbi:refreshPolicy": {
					"$type": "DeltaRefreshPolicy",
					"location": "' + @TableName + '.csv"
				},
				"Attributes": [
		'
	end
/*
print 'hi'
print '	"Name": "'+@ColumnName+'",'
print '	"DataType": "'+@JSONDataType+'"'
print '"IsNullable": "'+@IsNullable+'",'
print '	"CharacterMaximumLength": "'+ cast(isnull(@CharacterMaximumLength,'') as nvarchar(20)) +',"'
print '	"NumericPercision": "'+ cast(isnull(@NumericPrecision,'') as nvarchar(20)) +',"'
print '	"NunericScale": "'+ cast(isnull(@NumericScale,'') as nvarchar(20)) +'"'
*/

	if @Cnt < @Max
	begin
		select @JSONString = @JSONString + '
						{
						"Name": "'+@ColumnName+'",
						"DataType": "'+@JSONDataType+'"
						"IsNullable": "'+@IsNullable+'",
						"CharacterMaximumLength": "'+ cast(isnull(@CharacterMaximumLength,'') as nvarchar(20)) +'",
						"NumericPercision": "'+ cast(isnull(@NumericPrecision,'') as nvarchar(20)) +'",
						"NumericScale": "'+ cast(isnull(@NumericScale,'') as nvarchar(20)) +'"
					},
					'
		--print @JSONString
	end
	if @Cnt = @Max
	begin
		select @JSONString = @JSONString +'
		{
						"Name": "'+@ColumnName+'",
						"DataType": "'+@JSONDataType+'"
						"IsNullable": "'+@IsNullable+'",
						"CharacterMaximumLength": "'+ cast(isnull(@CharacterMaximumLength,'') as nvarchar(20)) +'",
						"NumericPercision": "'+ cast(isnull(@NumericPrecision,'') as nvarchar(20)) +'",
						"NumericScale": "'+ cast(isnull(@NumericScale,'') as nvarchar(20)) +'"
		}
	]
}'
		--print @JSONString
	end
	
	select	 @Cnt = @Cnt + 1

--	print 'Count : ' + cast(@cnt as varchar(20))
end

	--print @JSONString
	select @pJSONString = @JSONString
	--print @pJSONString
--return

end

