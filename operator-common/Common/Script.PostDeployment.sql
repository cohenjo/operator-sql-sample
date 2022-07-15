-- This file contains SQL statements that will be executed after the build script.
MERGE INTO [dbo].[NotificationStatus] AS Target 
USING (VALUES
  (1, 'Unspecified'),
  (2, 'New'),
  (3, 'InProgress'),
  (4, 'Resolved'),
  (5, 'Aborted'),
  (10, 'Hidden')
) AS Source (StatusId, StatusName) 
ON Target.StatusId = Source.StatusId 

WHEN MATCHED THEN 
UPDATE SET StatusName = Source.StatusName 
WHEN NOT MATCHED BY TARGET THEN 
INSERT (StatusId, StatusName) 
VALUES (StatusId, StatusName);

GO