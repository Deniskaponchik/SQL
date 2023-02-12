--USE [ANALYTICSS]
USE BPMonline7_14880

/*GO
Object:  View [dbo].[VwBPMWO_Executor_Personal_All_4CRM]    Script Date: 05.04.2022 10:05:00 --ЭТА СТРОКА БЫЛА ЗАКОММЕНТИРОВАНА
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[VwBPMWO_Executor_Personal_All_4CRM]
AS
SELECT  *
FROM            OPENROWSET('SQLNCLI', 'Server=t2ru-bpmdb-read\BPMOnline;UID=helper;PWD=b4vax;', '*/

Select 
						 wo.UsrNumber [Номер_WA],
						 wo.Id[ID_number],
						 Executors.FIO [Исполнитель_(ФИО)],
						 Executors.samaccountname [Исполнитель_UID_(samaccountname)],
						 wos.Name[Состояние_(имя)],
						 wot.name[Тип_работ_(имя)],
						 bd.Name[Краткое описание (имя)],
						 wod.Name[Направление (имя)],
						 wod.Id[Направление (GUID)],
						 wo.UsrDescription[Описание (текст)],
						 contt.name[Автор (ФИО)],
						 sauu.Name[Автор UID (samaccountname)],
						 ccont.Name[Ответственный (ФИО)],
						 ssau.Name[Ответственный UID (samaccountname)],
						 dateadd(HOUR,3,wo.UsrPlannedTimeStart)[Планируемое начало (дата/время)],
						 dateadd(HOUR,3,wo.UsrPlannedTimeEnd)[Планируемое окончание (дата/время)],
						 dateadd(HOUR,3,wo.UsrFactStartDate)[Фактическое начало (дата/время)],
						 dateadd(HOUR,3,wo.UsrFactEndDate)[Фактическое окончание (дата/время)],
						 dateadd(HOUR,3,Wo.ModifiedOn)[Дата изменения (дата/время)]

     from /*BPMONline7.dbo.*/UsrWorkOrder WO
left join /*BPMONline7.dbo.*/UsrWOStatus wos on wos.Id=wo.UsrWOStatusId
left join /*BPMONline7.dbo.*/UsrWOType wot on wot.id=wo.UsrWOTypeId
left join /*BPMONline7.dbo.*/UsrBriefDescription bd on bd.id=wo.UsrShortDescriptionId
left join /*BPMONline7.dbo.*/UsrWODestination wod on wod.Id=wo.UsrWODestinationId
left join /*BPMONline7.dbo.*/Contact contt on contt.Id=wo.UsrAuthorId
left join /*BPMONline7.dbo.*/SysAdminUnit sauu on sauu.ContactId = contt.Id
left join /*BPMONline7.dbo.*/Contact ccont on ccont.Id=wo.UsrOwnerId
left join /*BPMONline7.dbo.*/SysAdminUnit ssau on ssau.ContactId = ccont.Id

OUTER APPLY ( --Уникальность строки формирует сочетание Номер WA+исполнитель, т.е. на каждого исполнителя в рамках 1 наряда отдельная строка в представлении.
	SELECT 		 cont.Name[FIO],
				 sau.Name [samaccountname]
	FROM  /*BPMONline7.dbo.*/UsrWOExecutors WOE
left join /*BPMONline7.dbo.*/Contact cont on cont.Id=woe.UsrContactId
left join /*BPMONline7.dbo.*/SysAdminUnit sau on sau.ContactId = cont.Id
	WHERE WOE.UsrWorkOrderId=WO.Id
) Executors

where wod.Name like 'CRM%' AND WO.CreatedOn >= dateadd(day,-31,getdate())
/*where wod.Name like ''CRM%''')
                          AS derivedtbl_1
GO*/

ORDER BY WO.CreatedOn DESC


