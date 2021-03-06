USE [SQLAdmin]
GO

CREATE procedure [dbo].[usp_GetJSONDefinitionForSchema](
		 @pSchemaName		nvarchar(255)
		,@pVersion			nvarchar(255)
		,@pJSONString		nvarchar(max) output
		,@pVerbose			bit = 0
)

as
/*****************************************************************************
File:           usp_GetJSONDefinitionForSchema.sql
Name:           usp_GetJSONDefinitionForSchema
Purpose:        Take the list of objects and .


DROP TABLE IF EXISTS dbo.ModelJSON
create table dbo.ModelJSON (SchemaName nvarchar(255), ModelJSON nvarchar(max))

declare @JSONString nvarchar(max)
	,@SchemaName nvarchar(255) = 'dbo'

delete dbo.ModelJSON

exec dbo.usp_GetJSONDefinitionForSchema
	 @pSchemaName	= @SchemaName
	,@pVersion		= '1.0'
	,@pJSONString	= @JSONString output

print '****************************** Final String **********************************'
insert into  ModelJSON values (@SchemaName, @JSONString)

select ModelJSON from dbo.ModelJSON 
	

 Parameters:    



 Called by:      Application
 Calls:          usp_GetJSONDefinitionForTable

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
		,@Cnt						int	=	-1
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
		,@DataType					nvarchar(255)
		,@CharacterMaximumLength	int
		,@NumericPrecision			int
		,@NumericScale				int
		,@DataTimePercision			int
		,@JSONDataType				nvarchar(50) = ''
		,@JSONEntityString			nvarchar(max) = ''

declare	@TableList table 
(
		 TableListId				int identity(1,1)
		,TableName					nvarchar(255)

)

insert into @TableList (
		 TableName
)
SELECT TABLE_NAME
FROM c2000.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @pSchemaName
	--									/*REMOVE THIS LINE*/ and TABLE_NAME = 'FaFundSourceType'

	AND TABLE_NAME IN (
--'SyCampus','FaNSLDSWORK12','FaNSLDSWORK11','FaNSLDSWORK10','FaNSLDSWORK09','FaNSLDSWORK08'
--,'FaIsirNSLDSLoanSparseData','FaIsirSparseData','FaIsirNSLDSGrantSparseData','FaISIR05'
--,'FaISIR06','FaISIR10','FaISIR11','FaISIR12','FaISIR07','FaISIR08','FaISIR09'
--
--
--,'FaISIRAwardYearSchema','SyStudent','FaStudentAY'
--,'FaIsirNSLDSSparseData','FaISIRMain','FAISIRMatch'
--,'FaISIRRejection','FaISIRStudentMatch','FaLender','FaLoan'
--,'FaNSLDS06','FaNSLDS07','FaNSLDS08','FaNSLDS09','FaNSLDS10','FaNSLDS11','FaNSLDS12'
--
--,'FaNSLDSGrant08','FaNSLDSGrant09','FaNSLDSGrant10','FaNSLDSGrant11','FaNSLDSGrant12'
--,'FaNSLDSLoan05','FaNSLDSLoan06','FaNSLDSLoan07','FaNSLDSLoan08','FaNSLDSLoan09'
--,'FaNSLDSLoan10','FaNSLDSLoan11','FaNSLDSLoan12'
--,'FaNSLDSPell05','FaNSLDSPell06','FaNSLDSPell07'
--,'FaNSLDSWORK05','FaNSLDSWORK07','FaNSLDSWORK06'
--,'FaPackStatus','FaRefund','FaSched','FaServicer','FaStudentAid','FaStudentAYPaymentPeriod'
--,'FaSysComments','FaYear','LMLoanStatus','SaAcctStatus'

--'SaBillCode','SaCollectionAccountStatus','SaEnrollRevenue','SaRevenueDetail'
--,'SaStipend','SaTrans','SaTuitionDiscountPolicy','SaTuitionDiscountPolicyStudentGroup'
--,'SyAddress','SyAddrType','SyAdvisorByEnroll','SyAudit_AdEnroll'
--,'SyAudit_AdEnrollSched','SyAudit_CmDocument','SyAudit_SyAdvisorByEnroll'
--,'SyAudit_SyStaff','SyAudit_SyStudent','SyCampusList','SyCountry'
--,'AdAttend','AdAttribute','AdCalendar','AdCatalogYear','AdCIPCode'
--,'AdClassSched','AdClassSchedBookList','AdClassSchedInstructor'
--,'AdClassSchedTerm','AdConcentration','AdConcentrationByEnrollment'
--,'AdConcentrationByProgramVersion','AdConcentrationByProgramVersionCatalogYear'
--,'AdConcentrationRequirementRule','AdConcentrationType'
--,'AdCourse','AdCourseLevel','AdCourseStatusChangeReason','AdCourseType','AdDegree'
--,'AdDeliveryMethod','AdEnroll','AdEnrollDegree'
--,'AdEnrollSched','AdEnrollSchedStatusChanges','AdCIPCode'
--,'AdEnrollTerm','AdGradeLetter','AdGradeLevel','AdGradeScale','AdProgram'
--,'AdProgramCourse','AdProgramGroup','AdProgramRequirementRule','AdProgramVersion'
--,'AdProgramVersionProgramGroup','AdReason','AdRequirementRule'
--,'AdRequirementRuleAttribute','AdSapStatus','AdShift'
--,'AdTerm','amAgency','AmCollege','AmCollegeTransfer','AmExtraCurr'
--,'AmHighSchool','AmLeadType','AmMarital','AmNationality','AmPrevEduc'
--,'AmRace','BsItem','CmDocStatus','CmDocType','CmDocTypeByProgram'
--,'CmDocument','CmEvent','CmEventHistory_ro'
--,'CmEventResult','CmEventStatus'
--,'CmTemplate','FaDisb','FaBatchExpImp'
--,'FaFundSource','FaGuarantor'
--,'SyGroups','SyHold','SySchoolStatus','SyStaff','SyStaffGroup'
--,'SyStaffByGroup','SyStatChange','SyState','SyStatus'
--,'SyStudentAmRace','SyStudGrp','SyUserDict','SyUserValues','AdAttStat'
--,'AdCourseEquiv','AdProgramCourseCategory','AdProgramCourseCategoryCatalogYear'
--,'AmProspectTest','amTest','CmDocumentPolicy','CmDocumentPolicyDetail','CmPolicy'
--,'cmSisQueue','saBillingMethod','SyAudit_SySecurity','SyAudit_SyStaffbyGroup'
--,'SyFormAccess','SyRegistry'
--,'SySecurity','SyUserLog','FaFundSourceType','SyCode','SyStatusCategory'
'AdEnrollSched'
)
GROUP BY TABLE_NAME

/*
DROP TABLE IF EXISTS dbo.ModelJSON
create table dbo.ModelJSON (SchemaName nvarchar(255), ModelJSON nvarchar(max))

declare @JSONString nvarchar(max)
	,@SchemaName nvarchar(255) = 'dbo'

delete dbo.ModelJSON

exec dbo.usp_GetJSONDefinitionForSchema
	 @pSchemaName	= @SchemaName
	,@pVersion		= '1.0'
	,@pJSONString	= @JSONString output

print '****************************** Final String **********************************'
insert into  ModelJSON values (@SchemaName, @JSONString)

DECLARE @xml XML;
select @xml = ModelJSON from dbo.ModelJSON 
select @xml

*/

-- select  * from @ParameterList

if exists (select top 1 1 from @TableList)
	begin
		select	 @Cnt			= 1
				,@Max			= (select max(TableListId) from @TableList)
	end
else
	begin
		select @JSONString = ''
		return
	end



-- Prepare Json Header
		select @JSONString = 
'{
    "application":"Model JSON"
	"name": "'+ @pSchemaName +'",
    "description": "",
    "version": "'+@pVersion+'",
	"modifiedtime":"'++'",'

-- Lets go get all the entities
while  @Cnt <= @Max and @Cnt <> -1
begin

	select	 @TableName		= TableName
	from	 @TableList
	where	 TableListId	= @Cnt

	

	if @Cnt = 1 
	begin
		select @JSONString = @JSONString + '    "entities": [' + @CRLF
	end


	if @Cnt <= @Max
	begin
		exec dbo.usp_GetJSONDefinitionForTable 
				 @pTableName = @TableName
				,@pSchemaName = @pSchemaName
				,@pJSONString = @JSONEntityString output

		select @JSONString = @JSONString + @JSONEntityString
		--print 'Entity: ' + @JSONEntityString

	end

	
	if @Cnt = @Max
	begin
		select @JSONString = @JSONString +'
	]'
	end
		
	select	 @Cnt = @Cnt + 1

	
end -- while loop for entitry

-- Lets loop again for foreign keys
if exists (select top 1 1 from @TableList)
	begin
		select	 @Cnt			= 1
				,@Max			= (select max(TableListId) from @TableList)

		select @JSONString = @JSONString + '"references":['
	end

-- Lets go get all the entities
while  @Cnt <= @Max and @Cnt <> -1
begin

	select	 @TableName		= TableName
	from	 @TableList
	where	 TableListId	= @Cnt

	exec dbo.usp_GetJSONDefinitionForForeignKeyOnTable 
				@pTableName = @TableName
			,@pSchemaName = @pSchemaName
			,@pJSONString = @JSONEntityString output

	select @JSONString = @JSONString + @JSONEntityString

	if  @Cnt = @Max 
		select @JSONString = @JSONString + ']'

	select @Cnt = @Cnt + 1

end -- getting foreign keys

-- return the rest of this to the user

	--print @JSONString
	select @pJSONString = @JSONString + '}'

return

end

