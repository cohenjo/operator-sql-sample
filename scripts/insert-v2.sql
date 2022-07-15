
INSERT INTO [operatore-test-v1].[TestTenant].[TestTable1]
VALUES
  (1, 1, 'Test-Name', 'Test-MSG');


SELECT TOP (1000)
  [Id]
      , [StatusId]
      , [Name]
      , [MessageText]
FROM [operatore-test-v1].[TestTenant].[TestTable1]