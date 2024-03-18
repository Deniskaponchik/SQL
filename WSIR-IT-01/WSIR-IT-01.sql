/*Таблица с логами SMAC. Может вносить промежуточные ошибки ДО того, как начинает очистку в поле Comment*/
SELECT TOP (100) [id],[PCname],[UserFIO],[AdminFIO],[DateAdd],[Comment]
--,[AdminLogin],[UserLogin],[ip],[SRnumber],[SRlink],[IncidentType],[WorkType]
FROM [Itsupport].[dbo].[SmacPC] ORDER BY id DESC
select Comment from Itsupport.dbo.SmacPC where DATALENGTH(Comment) > 0 /*Заношу ошибки и читаю ошибки скрипта*/

/*Таблица с логами ошибок по всем скриптам. Ошибки вносятся по ЗАВЕРШЕНИИ скрипта*/
SELECT TOP (1000) * FROM [Itsupport].[dbo].[ScriptExecute] ORDER BY id DESC
select * from Itsupport.dbo.ScriptExecute where FeedBack is not null OR FeedBack not like ' ' order by id desc
select * from Itsupport.dbo.ScriptExecute where DATALENGTH(FeedBack) > 0 order by id desc
INSERT INTO Itsupport.dbo.ScriptExecute (DateStart, AdminLogin, AdminFIO, ScriptName, FeedBack, Error) VALUES('2024-02-03 18:18:31.860', 'TEST', 'TEST', 'TEST', 'TEST', 'TEST')

select * from Itsupport.dbo.RegionCodes