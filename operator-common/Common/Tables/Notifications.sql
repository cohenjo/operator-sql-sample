CREATE TABLE [dbo].[Notifications]
(
  [NotificationId] INT IDENTITY(1,1) NOT NULL,
  [StatusId] INT NOT Null,
  [OrgId] VARCHAR(100) NOT NULL,
  [Name] NVARCHAR(100) NOT NULL
)