CREATE PROCEDURE [@@@SchemaName@@@].[@@@ProcedureName@@@] (
	 @pIssueId			int = -1
	,@pETLExecutionId	int	= -1
	,@pPathId			int = -1
	,@pVerbose			bit	= 0)
AS
/*****************************************************************************
File:		@@@SchemaName@@@.@@@ProcedureName@@@.sql
Name:		@@@SchemaName@@@.@@@ProcedureName@@@
Purpose:	
Example:	exec @@@SchemaName@@@.@@@ProcedureName@@@
Parameters:    
Called by:	
Calls:          
Errors:		
Author:		Generated from version @@@Version@@@
Date:		@@@Date@@@
*******************************************************************************
							CHANGE HISTORY
*******************************************************************************
Date		Author								Description
--------	-------------						--------------------------------
@@@Date@@@	Generated							Initial Iteration

******************************************************************************/

-------------------------------------------------------------------------------
--  Declarations
-------------------------------------------------------------------------------
DECLARE	 @Rows					varchar(10)		= 0
        ,@ErrNum				int				= -1
		,@ErrMsg				nvarchar(2048)	= 'N/A'
		,@ParametersPassedChar	varchar(1000)   = 'N/A'
		,@CRLF					varchar(10)		= char(13) + char(10)
		,@ProcName				varchar(256)	= OBJECT_NAME(@@PROCID) 
		,@ParentStepLogId       int				= -1
		,@PrevStepLog			int				= -1
		,@ProcessStartDtm		datetime		= getdate()
		,@CurrentDtm			datetime		= getdate()
		,@PreviousDtm			datetime		= getdate()
		,@DbName				varchar(50)		= DB_NAME()
		,@CurrentUser			varchar(256)	= CURRENT_USER
		,@ProcessType			varchar(10)		= 'Proc'
		,@StepName				varchar(256)	= 'Start'
		,@StepOperation			varchar(50)		= 'N/A' 
		,@MessageType			varchar(20)		= 'Info' -- ErrCust, ErrSQL, Info, Warn
		,@StepDesc				nvarchar(2048)	= 'Procedure started' 
		,@StepStatus			varchar(10)		= 'Success'
		,@StepNumber			varchar(10)		= 0
		,@Duration				varchar(10)		= 0
		,@JSONSnippet			nvarchar(max)	= 'N/A'

-------------------------------------------------------------------------------
--  Initializations
-------------------------------------------------------------------------------
SELECT	 @ParametersPassedChar	= 
			'exec @@@SchemaName@@@.@@@ProcedureName@@@' + @CRLF +
			'    ,@pIssueId = ' + isnull(cast(@pIssueId as varchar(100)),'NULL') + @CRLF + 
			'    ,@pETLExecutionId = ' + isnull(cast(@pETLExecutionId as varchar(100)),'NULL') + @CRLF + 
			'    ,@pPathId = ' + isnull(cast(@pPathId as varchar(100)),'NULL') + @CRLF + 
			'    ,@pVerbose = ' + isnull(cast(@pVerbose as varchar(100)),'NULL')

IF @pVerbose					= 1
BEGIN 
	PRINT @ParametersPassedChar
END

-------------------------------------------------------------------------------
--  Log Procedure Start
-------------------------------------------------------------------------------
EXEC [audit].[usp_InsertStepLog]
		 @MessageType		,@CurrentDtm		,@PreviousDtm	,@StepNumber		,@StepOperation		,@JSONSnippet		,@ErrNum
		,@ParametersPassedChar					,@ErrMsg output	,@ParentStepLogId	,@ProcName			,@ProcessType		,@StepName
		,@StepDesc output	,@StepStatus		,@DbName		,@Rows				,@pETLExecutionId	,@pPathId			,@ParentStepLogId output	
		,@pVerbose

-------------------------------------------------------------------------------
--  Main Code Block
-------------------------------------------------------------------------------
BEGIN TRY

-------------------------------------------------------------------------------
--  Log Main Step
-------------------------------------------------------------------------------
SELECT	 @StepName			= 'Step 1 of 1: Merge sis_CampusNexus @@@TableName@@@ Data'
		,@StepNumber		= @StepNumber + 1
		,@StepOperation		= 'Merge'
		,@StepDesc			= 'Merge @@@SchemaName@@@.@@@TableName@@@ Data for Reporting'


BEGIN
	MERGE @@@TargetDataBaseName@@@.@@@SchemaName@@@.@@@TableName@@@ AS target
	USING (
		SELECT @@@ParameterSelect@@@
		FROM @@@SourceDatabase@@@.@@@SchemaName@@@.@@@TableName@@@
		WHERE [IssueId] = @pIssueId
		) AS source
		ON (target.@@@TableName@@@Id = source.@@@TableName@@@Id)
	WHEN MATCHED
		THEN
			UPDATE
			SET 
				@@@ParameterUpdate@@@,	[IssueId] = @pIssueId
	WHEN NOT MATCHED
		THEN
			INSERT (
				@@@ParameterList@@@,	[IssueId]
				)
			VALUES (
				@@@ParameterInsert@@@,	@pIssueId
				);
END

	SELECT
			 @PreviousDtm		= @CurrentDtm
			,@Rows				= @@ROWCOUNT 
			,@CurrentDtm		= getdate()
			,@JSONSnippet		= @JSONSnippet

	EXEC [audit].usp_InsertStepLog
			 @MessageType		,@CurrentDtm		,@PreviousDtm	,@StepNumber		,@StepOperation		,@JSONSnippet		,@ErrNum
			,@ParametersPassedChar					,@ErrMsg output	,@ParentStepLogId	,@ProcName			,@ProcessType		,@StepName
			,@StepDesc output	,@StepStatus		,@DbName		,@Rows				,@pETLExecutionId	,@pPathId			,@PrevStepLog output
			,@pVerbose
	
END TRY

-------------------------------------------------------------------------------
--  Error Handling
-------------------------------------------------------------------------------
BEGIN CATCH

	SELECT 	 @PreviousDtm		= @CurrentDtm
			,@ErrNum			= @@ERROR
			,@ErrMsg			= ERROR_MESSAGE()
			,@Rows				= 0

	select	 @StepStatus		= 'Failure'
			,@CurrentDtm		= getdate()

	IF		 @MessageType		<> 'ErrCust'
		SELECT   @MessageType	= 'ErrSQL'

	EXEC [audit].usp_InsertStepLog
			 @MessageType		,@CurrentDtm		,@PreviousDtm	,@StepNumber		,@StepOperation		,@JSONSnippet		,@ErrNum
			,@ParametersPassedChar					,@ErrMsg output	,@ParentStepLogId	,@ProcName			,@ProcessType		,@StepName
			,@StepDesc output	,@StepStatus		,@DbName		,@Rows				,@pETLExecutionId	,@pPathId			,@PrevStepLog output
			,@pVerbose

	IF 	@ErrNum < 50000	
		SELECT	 @ErrNum	= @ErrNum + 100000000 -- Need to increase number to throw message.

	;THROW	 @ErrNum, @ErrMsg, 1
	
END CATCH

-------------------------------------------------------------------------------
--  Log Procedure End
-------------------------------------------------------------------------------
SELECT 	 @PreviousDtm			= @CurrentDtm
		,@CurrentDtm			= getdate()
		,@StepNumber			= @StepNumber + 1
		,@StepName				= 'End'
		,@StepDesc				= 'Procedure completed'
		,@Rows					= 0
		,@StepOperation			= 'N/A'

-- Passing @ProcessStartDtm so the total duration for the procedure is added.
-- @ProcessStartDtm (if you want total duration) 
-- @PreviousDtm (if you want 0)

EXEC [audit].usp_InsertStepLog
		 @MessageType ,@CurrentDtm ,@ProcessStartDtm ,@StepNumber ,@StepOperation ,@JSONSnippet ,@ErrNum
		,@ParametersPassedChar, @ErrMsg OUTPUT, @ParentStepLogId ,@ProcName, @ProcessType ,@StepName
		,@StepDesc OUTPUT, @StepStatus, @DbName, @Rows, @pETLExecutionId ,@pPathId, @PrevStepLog output
		,@pVerbose
------------------------------------------------------