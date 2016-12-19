SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[WorkItemCustomFieldValue]'))
DROP VIEW dbo.WorkItemCustomFieldValue
GO

CREATE VIEW dbo.WorkItemCustomFieldValue 
-- Custom fields uses to be mapped to a bunch of fields each table had in TFS that were 
-- prefixed with fld, you then had to map these back to dbo.Fields table using ColName
-- I've created this so I dont have to join two tables per field, i've also limited the reference name
-- down to what I need, but it could be opened up
-- an alternate using a Pivot instead is available 
AS
SELECT
	WCL.Id AS WorkItemID
	,F.ReferenceName
	,WCL.IntValue
	,WCL.FloatValue
	,WCL.DateTimeValue
	,WCL.GuidValue
	,WCL.BitValue
	,CONVERT(varchar(200), ISNULL(WCL.StringValue, WCL.TextValue)) AS StringValue -- for simplicity, but not accuracy
FROM	
	dbo.tbl_WorkItemCustomLatest WCL  WITH (NOLOCK)
	INNER JOIN dbo.tbl_Field F WITH (NOLOCK) ON F.PartitionId = wcl.PartitionId
								AND F.FieldId = wcl.FieldId
								AND F.IsDeleted = 0
WHERE
	F.ReferenceName IN (
			'System.Title' -- I have no idea why this is a custom field, its crazy, every item has a title!
			,'Microsoft.VSTS.Common.ClosedDate'
			,'Microsoft.VSTS.CMMI.TargetResolveDate'
			,'Microsoft.VSTS.Common.ClosedBy'
			,'Microsoft.VSTS.Scheduling.RemainingWork'
			,'Microsoft.VSTS.Scheduling.CompletedWork'
			-- custom field types as required
			)
GO