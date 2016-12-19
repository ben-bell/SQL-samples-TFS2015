SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[WorkItemsLatestUsed]'))
DROP VIEW dbo.WorkItemsLatestUsed
GO

CREATE VIEW dbo.WorkItemsLatestUsed 
-- recreation of TFS 2010 table, I've done a whole heap of converts to varchar(200) purely because in our
-- reporting we assign string values to a variable using multi select and this doesnt work with varchar(max)
-- or text fields... technically its not correct, but I dont need those values to have more than 200 characters
AS 
SELECT
		wl.PartitionId
		,CONVERT(varchar(200), N.TeamProject) AS [System.TeamProject]
		,wl.Id [System.Id]
		,wl.Rev [System.Rev]
		,WL.AreaID
		,wl.AuthorizedDate [System.AuthorizedDate]
		,wl.RevisedDate [System.RevisedDate]
		,wl.AuthorizedAs [System.AuthorizedAs]
		,CONVERT(varchar(200),wl.WorkItemType) AS [System.WorkItemType]
		--,wl.AreaPath [System.AreaPath]
		,wl.AreaId [System.AreaId]
		--,wl.IterationPath [System.IterationPath]
		,wl.IterationId [System.IterationId]
		,wl.CreatedBy [System.CreatedBy]
		,CONVERT(varchar(200), RAI.NamePart) AS CreatedByUser
		,CONVERT(varchar(200), RAI.DisplayPart) AS CreatedByDisplay
		,wl.CreatedDate [System.CreatedDate]
		,wl.ChangedBy [System.ChangedBy]
		,wl.ChangedDate [System.ChangedDate]
		,CONVERT(varchar(200), wl.State) AS [System.State]
		,CONVERT(varchar(200), wl.Reason) AS [System.Reason]
		,CONVERT(varchar(200), wl.AssignedTo) AS [System.AssignedTo]
		,CONVERT(varchar(200), ASS.NamePart) AS AssignedToUser
		,CONVERT(varchar(200), ASS.DisplayPart) AS AssignedToDisplay
		,wl.Watermark  [System.Watermark]
		-- these are all custome fields below, I know what type of field its going to be
		-- so I grab that value directly
		,RST.StringValue AS [System.Title]
		,RCD.DateTimeValue AS [Microsoft.VSTS.Common.ClosedDate]
		,RTRD.DateTimeValue AS [Microsoft.VSTS.CMMI.TargetResolveDate]
		,RCB.IntValue AS [Microsoft.VSTS.Common.ClosedBy]
		,RRW.FloatValue AS [Microsoft.VSTS.Scheduling.RemainingWork]
		,RCW.FloatValue AS [Microsoft.VSTS.Scheduling.CompletedWork]
		-- dont follow our lead, use the same field for target resolve time or you'll
		-- be doing something like I've done below!
		,CASE WL.WorkItemType
			WHEN 'Data Fix' THEN CONVERT(Date,DATEADD(hour, 12, RDB.DateTimeValue))
			WHEN 'Risk' THEN CONVERT(Date,DATEADD(hour, 12, WL.CreatedDate))
			WHEN 'Issue' THEN CONVERT(Date,DATEADD(hour, 12, WL.CreatedDate))
			ELSE CONVERT(Date,DATEADD(hour, 12, RTRD.DateTimeValue))
		END AS TargetResolveDate
FROM
		dbo.tbl_workItemCoreLatest WL WITH (NOLOCK)
		INNER JOIN dbo.WorkItemCustomFieldValue RST WITH (NOLOCK) ON WL.Id = RST.WorkItemId AND RST.ReferenceName = 'System.Title'
		LEFT JOIN dbo.WorkItemCustomFieldValue RCD WITH (NOLOCK) ON WL.Id = RCD.WorkItemId AND RCD.ReferenceName = 'Microsoft.VSTS.Common.ClosedDate'
		LEFT JOIN dbo.WorkItemCustomFieldValue RTRD WITH (NOLOCK) ON WL.Id = RTRD.WorkItemId AND RTRD.ReferenceName = 'Microsoft.VSTS.CMMI.TargetResolveDate'
		LEFT JOIN dbo.WorkItemCustomFieldValue RCB WITH (NOLOCK) ON WL.Id = RCB.WorkItemId AND RCB.ReferenceName = 'Microsoft.VSTS.Common.ClosedBy'
		LEFT JOIN dbo.WorkItemCustomFieldValue RRW WITH (NOLOCK) ON WL.Id = RRW.WorkItemId AND RRW.ReferenceName = 'Microsoft.VSTS.Scheduling.RemainingWork'
		LEFT JOIN dbo.WorkItemCustomFieldValue RCW WITH (NOLOCK) ON WL.Id = RCW.WorkItemId AND RCW.ReferenceName = 'Microsoft.VSTS.Scheduling.CompletedWork'
		LEFT JOIN dbo.tbl_ClassificationNodePath N ON WL.AreaID = N.ID
		LEFT JOIN dbo.Constants ASS ON WL.AssignedTo = ASS.ConstID
		LEFT JOIN dbo.Constants RAI ON WL.CreatedBy = RAI.ConstID
WHERE
		wl.WorkItemType IN ('Change Request', 'Data Fix', 'Bug', 'Test Case', 'Release', 'Activity')
GO