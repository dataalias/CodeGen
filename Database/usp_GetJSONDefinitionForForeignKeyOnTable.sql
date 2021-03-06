USE [SQLAdmin]
GO

CREATE procedure [dbo].[usp_GetJSONDefinitionForForeignKeyOnTable](
		 @pTableName		nvarchar(255)
		,@pSchemaName		nvarchar(255)
		,@pJSONString		nvarchar(max) output
		,@pVerbose			bit = 0
)

as
/*****************************************************************************
File:           usp_GetJSONDefinitionForForeignKeyOnTable.sql
Name:           usp_GetJSONDefinitionForForeignKeyOnTable
Purpose:        Take the list of objects and .

declare @JSONString nvarchar(max) = ''
exec dbo.usp_GetJSONDefinitionForForeignKeyOnTable 
	 @pTableName = 'AdClassSched'
	,@pSchemaName = 'dbo'
	,@pJSONString = @JSONString output
print '****************************** Final Output ******************************'
print @JSONString
	

 Parameters:    



 Called by:      Application
 Calls:          

 Author:         ffortunato
 Date:           20210202

*******************************************************************************
       CHANGE HISTORY
*******************************************************************************
Date		Author         Description
--------	-------------	---------------------------------------------------
20210202	ffortunato		Initial Iteration

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
		,@ForeignKeyKeyName			nvarchar(255)
		,@TableWithForeignKey		nvarchar(255)
		,@TableWithLocalKey			nvarchar(255)
		,@ConstrainedColumn			nvarchar(255)
		,@ReferencedColumn			nvarchar(255)
		,@ColumnId					int

declare	@ForeignKeyList table 
(
		 ForeignKeyListId			int identity(1,1)
		,ForeignKeyKeyName			nvarchar(255)
		,TableWithForeignKey		nvarchar(255)
		,TableWithLocalKey			nvarchar(255)
		,ConstrainedColumn			nvarchar(255)
		,ReferencedColumn			nvarchar(255)
		,ColumnId					int
)

insert into @ForeignKeyList (
		 ForeignKeyKeyName
		,TableWithForeignKey
		,TableWithLocalKey
		,ConstrainedColumn
		,ReferencedColumn
		,ColumnId
)
select 
     fk.name	as ForeignKeyKeyName
    ,pt.name	as TableWithForeignKey
	,ct.name	as TableWithLocalKey
	,cl.name	as ConstrainedColumn
	,cl2.name	as ReferencedColumn
	,fkc.constraint_column_id as ColumnId
	--,ss.name	as SchemaName
	--,pt.schema_id as SchemaId
	--,name as ForeignKeyColumn 
	--,*
from		c2000.sys.foreign_key_columns	  fkc
join		c2000.sys.tables				  pt 
on			fkc.parent_object_id	= pt.object_id
join		c2000.sys.foreign_keys		  fk
on			fk.object_id			= fkc.constraint_object_id
join		c2000.sys.tables				  ct 
on			fkc.referenced_object_id= ct.object_id
join		c2000.sys.columns				  cl 
on			fkc.parent_object_id	= cl.object_id 
and			fkc.parent_column_id	= cl.column_id
join		c2000.sys.columns				  cl2 
on			fkc.referenced_object_id= cl2.object_id 
and			fkc.referenced_column_id= cl2.column_id
join		c2000.sys.schemas				  ss
on			ss.schema_id			= pt.schema_id
where		1=1
and			ss.name = @pSchemaName
and			pt.name = @pTableName
order		by TableWithForeignKey, fkc.constraint_column_id

-- select  * from @ColumnList

if exists (select top 1 1 from @ForeignKeyList)
	begin
		select	 @Cnt			= 1
				,@Max			= (select max(ForeignKeyListId) from @ForeignKeyList)
	end
else
	begin
		select @pJSONString = ''
		return
	end

while  @Cnt <= @Max and @Cnt <> -1
begin

	select	 @ForeignKeyKeyName		= ForeignKeyKeyName	
			,@TableWithForeignKey	= TableWithForeignKey
			,@TableWithLocalKey		= TableWithLocalKey	
			,@ConstrainedColumn		= ConstrainedColumn	
			,@ReferencedColumn		= ReferencedColumn
			,@ColumnId				= ColumnId
	from	 @ForeignKeyList
	where	 ForeignKeyListId		= @Cnt

/*
print				'TableWithForeignKey: ' + @TableWithForeignKey
print				'TableWithLocalKey:   '	 + @TableWithLocalKey	
print				'ConstrainedColumn:   '	 + @ConstrainedColumn	
print				'ReferencedColumn:    '	 + @ReferencedColumn	
*/

	if @Cnt = 1 
	begin
		select @JSONString = 
		'        {
				"$type": "ReferenceEntity",
				"Name": "FK_' + @TableWithForeignKey + '_' + @TableWithLocalKey + '__' + @ConstrainedColumn + '_' + @ReferencedColumn +'",
				"description": "",
				"TableWithForeignKey":"' + @TableWithForeignKey	+ '",
				"TableWithLocalKey":"'	 + @TableWithLocalKey	+ '",
				"ConstrainedColumn":"'	 + @ConstrainedColumn	+ '",
				"ReferencedColumn":"'	 + @ReferencedColumn	+ '"
				}'
	end
/*
print 'hi10'
print @JSONString
*/

	if @Cnt <= @Max
	begin
		select @JSONString = @JSONString + 		
		'        {
				"$type": "ReferenceEntity",
				"Name": "FK_' + @TableWithForeignKey + '_' + @TableWithLocalKey + '__' + @ConstrainedColumn + '_' + @ReferencedColumn +'",
				"description": "",
				"TableWithForeignKey":"' + @TableWithForeignKey	+ '",
				"TableWithLocalKey":"'	 + @TableWithLocalKey	+ '",
				"ConstrainedColumn":"'	 + @ConstrainedColumn	+ '",
				"ReferencedColumn":"'	 + @ReferencedColumn	+ '"
				},'
	end
/*
print 'hi20'
print @JSONString
*/
/*
	if @Cnt = @Max
	begin
		select @JSONString = @JSONString +
		'{
				"$type": "ReferenceEntity",
				"Name": "FK_' + @TableWithForeignKey + '_' + @TableWithLocalKey + '__' + @ConstrainedColumn + '_' + @ReferencedColumn +'",
				"description": "",
				"TableWithForeignKey":"' + @TableWithForeignKey	+ '",
				"TableWithLocalKey":"'	 + @TableWithLocalKey	+ '",
				"ConstrainedColumn":"'	 + @ConstrainedColumn	+ '",
				"ReferencedColumn":"'	 + @ReferencedColumn	+ '"
				}
	]'
		--print @JSONString
	end
*/	
	select	 @Cnt = @Cnt + 1

--	print 'Count : ' + cast(@cnt as varchar(20))
end

	--print @JSONString
	select @pJSONString = @JSONString
	--print @pJSONString
--return

end

