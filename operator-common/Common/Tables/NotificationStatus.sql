CREATE TABLE [dbo].[NotificationStatus]
(
  [StatusId] INT NOT NULL,
  [StatusName] VARCHAR(50) NOT NULL,
  CONSTRAINT [PK_NotificationStatus] PRIMARY KEY CLUSTERED ([StatusId] ASC)
)
