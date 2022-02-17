Introduction
-------------------------------------------------------------------------------
These are a series if scripts that allow users to connect to a source SQL
Server database and pull all of the objects into a Model.JSON file for a given
schema. The assumption being that the target system will pull this information
into a data lake where the model.json can act as the shema. But wait there is
more... The model JSON can then be used to create target tables for a 
relational database. Then we assume you will want to merger that information
into the target store so we will create some merge t-sql stored procedures.

Code
-------------------------------------------------------------------------------

	Invoke-CreateModelJSON.ps1
-------------------------------------------------------------------------------
Creates model.JSON from source db.schema


	Invoke-GetDDLFromModelJSON.ps1
-------------------------------------------------------------------------------
Creates ddl from the model.json


	Invoke-GetODSMergeCodeFromModelJSON.ps1
-------------------------------------------------------------------------------
Creates t-sql merge code from the model.json

	usp_TemplateMergeProcedure.sql
-------------------------------------------------------------------------------
The template procedure that will be used in congunction with:
	Invoke-GetODSMergeCodeFromModelJSON.ps1
