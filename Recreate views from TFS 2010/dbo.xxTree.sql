SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[xxTree]'))
DROP VIEW dbo.xxTree
GO

CREATE VIEW dbo.xxTree
-- xxTree was a useful view in TFS 2010 storing area paths and levels
-- some of our custom reporting was built around it so I needed to
-- recreate it so we didnt have to change the reporting
AS

	SELECT
		N.ID
		,ParentID
		,CONVERT(varchar(200), NodeName) AS [Node Name]
		,CASE WHEN N.StructureType = 1 THEN
			CASE N.TypeID
				WHEN -43 THEN 'Area Level 1'
				WHEN -44 THEN 'Area Level 2'
				WHEN -45 THEN 'Area Level 3'
				WHEN -46 THEN 'Area Level 4'
				WHEN -47 THEN 'Area Level 5'
				WHEN -48 THEN 'Area Level 6'
				WHEN -49 THEN 'Area Level 7'
			END
			ELSE
			CASE N.TypeID
				WHEN -43 THEN 'Iteration Level 1'
				WHEN -44 THEN 'Iteration Level 2'
				WHEN -45 THEN 'Iteration Level 3'
				WHEN -46 THEN 'Iteration Level 4'
				WHEN -47 THEN 'Iteration Level 5'
				WHEN -48 THEN 'Iteration Level 6'
				WHEN -49 THEN 'Iteration Level 7'
			END
		END  AS [Node Type]
		,CONVERT(varchar(200), TeamProject) AS [Team Project]
		,CONVERT(varchar(200), AreaLevel1) AS [Area Level 1]
		,CONVERT(varchar(200), AreaLevel2) AS [Area Level 2]
		,CONVERT(varchar(200), AreaLevel3) AS [Area Level 3]
		,CONVERT(varchar(200), AreaLevel4) AS [Area Level 4]
		,CONVERT(varchar(200), AreaLevel5) AS [Area Level 5]
		,CONVERT(varchar(200), AreaLevel6) AS [Area Level 6]
		,CONVERT(varchar(200), AreaLevel7) AS [Area Level 7]
		,CONVERT(varchar(200), IterationLevel1) AS [Iteration Level 1]
		,CONVERT(varchar(200), IterationLevel2) AS [Iteration Level 2]
		,CONVERT(varchar(200), IterationLevel3) AS [Iteration Level 3]
		,CONVERT(varchar(200), IterationLevel4) AS [Iteration Level 4]
		,CONVERT(varchar(200), IterationLevel5) AS [Iteration Level 5]
		,CONVERT(varchar(200), IterationLevel6) AS [Iteration Level 6]
		,CONVERT(varchar(200), IterationLevel7) AS [Iteration Level 7]
		,CONVERT(varchar(200), AreaPath) AS [Area Path]
		,CONVERT(varchar(200), IterationPath) AS [Iteration Path]
		,ChangeDate AS [Changed Date]
		,[TeamProject]
			+ COALESCE ('\' + [AreaLevel2], '') 
			+ COALESCE ('\' + [AreaLevel3], '')
			+ COALESCE ('\' + [AreaLevel4], '')
			+ COALESCE ('\' + [AreaLevel5], '')
			+ COALESCE ('\' + [AreaLevel6], '')
			+ COALESCE ('\' + [AreaLevel7], '') AS FullAreaPath
	FROM
		tbl_ClassificationNode N
		INNER JOIN dbo.tbl_ClassificationNodePath NP ON N.Id = NP.Id
GO
