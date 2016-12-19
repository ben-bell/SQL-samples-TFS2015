SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[WorkItemCustomFieldValuePivot]'))
DROP VIEW dbo.WorkItemCustomFieldValuePivot
GO

CREATE VIEW dbo.WorkItemCustomFieldValuePivot
-- see dbo.WorkItemCustomFieldValue for a full rundown on why this is here
-- I've decided against pivot as I found it a bit heavier
AS
SELECT
		piv.Id
		,piv.PartitionId
		,piv.[System.Title]
		,piv.[Microsoft.VSTS.Common.ClosedDate]
		,piv.[Microsoft.VSTS.CMMI.TargetResolveDate]
		,piv.[Microsoft.VSTS.Common.ClosedBy]
		,piv.[Microsoft.VSTS.Scheduling.RemainingWork]
		,piv.[Microsoft.VSTS.Scheduling.CompletedWork]
FROM
	(
		SELECT
				WCL.PartitionId
				,WCL.Id
				,F.ReferenceName  
				,CASE 
					-- can either have each field individually or group them together but have to
					-- convert them all to the same type if we do that 
					WHEN ISNULL(WCL.IntValue,0) > 0			THEN CONVERT(varchar(max), WCL.IntValue)
					WHEN ISNULL(WCL.FloatValue,0) > 0		THEN CONVERT(varchar(max), WCL.FloatValue)
					WHEN WCL.DateTimeValue IS NOT NULL		THEN CONVERT(varchar(max), WCL.DateTimeValue)
					WHEN WCL.GuidValue IS NOT NULL			THEN CONVERT(varchar(max), WCL.GuidValue )
					WHEN ISNULL(WCL.StringValue,'') <> ''	THEN CONVERT(varchar(max), WCL.StringValue)
					WHEN ISNULL(WCL.TextValue,'') <> ''		THEN CONVERT(varchar(max), WCL.TextValue)
				END FieldValue
		FROM
				dbo.tbl_WorkItemCustomLatest WCL 
				JOIN dbo.tbl_Field F ON F.PartitionId = WCL.PartitionId
									AND F.FieldId = WCL.FieldId
									AND F.IsDeleted = 0
		) AS t
		PIVOT 
		(
		  MAX(FieldValue) 
		  FOR ReferenceName IN (
					[System.Title]
		  			,[Microsoft.VSTS.Common.ClosedDate]
					,[Microsoft.VSTS.CMMI.TargetResolveDate]
					,[Microsoft.VSTS.Common.ClosedBy]
					,[Microsoft.VSTS.Scheduling.RemainingWork]
					,[Microsoft.VSTS.Scheduling.CompletedWork])
		   ) AS piv;
GO
