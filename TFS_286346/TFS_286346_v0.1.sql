USE [ANALYTICSS]
GO

/****** Object:  View [dbo].[VwBPMWO_Executor_Personal_4CRM]    Script Date: 05.04.2022 10:05:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[VwBPMWO_Executor_Personal_4CRM]
AS
SELECT  *
FROM            OPENROWSET('SQLNCLI', 'Server=t2ru-bpmdb-read\BPMOnline;UID=helper;PWD=b4vax;', 
                         'Select 
						 wo.UsrNumber,
						 Wo.ModifiedOn,
						 wo.Id[ID_number],
						 cont.Name[executor],
						 sau.Name[executor_samaccountname],
						 wos.Name[condition],
						 wot.name[work_type],
						 bd.Name[short_desc],
						 wod.Name[Direction],
						 wod.Id[Direction_GUID],
						 wo.UsrDescription[Description],
						 contt.name[Author],
						 sauu.Name[Author_samaccountname],
						 ccont.Name[Responsible],
						 ssau.Name[Responsible_samaccountname],
						 wo.UsrPlannedTimeStart[PlannedTimeStart],
						 wo.UsrPlannedTimeEnd[PlannedTimeEnd],
						 wo.UsrFactStartDate[FactStartDate],
						 wo.UsrFactEndDate[FactEndDate]
from BPMONline7.dbo.UsrWorkOrder WO
left join BPMONline7.dbo.UsrWOExecutors WOE on WOE.UsrWorkOrderId=WO.Id
left join BPMONline7.dbo.Contact cont on cont.Id=woe.UsrContactId
left join BPMONline7.dbo.SysAdminUnit sau on sau.ContactId = cont.Id
left join BPMONline7.dbo.UsrWOStatus wos on wos.Id=wo.UsrWOStatusId
left join BPMONline7.dbo.UsrWOType wot on wot.id=wo.UsrWOTypeId
left join BPMONline7.dbo.UsrBriefDescription bd on bd.id=wo.UsrShortDescriptionId
left join BPMONline7.dbo.UsrWODestination wod on wod.Id=wo.UsrWODestinationId
left join BPMONline7.dbo.Contact contt on contt.Id=wo.UsrAuthorId
left join BPMONline7.dbo.SysAdminUnit sauu on sauu.ContactId = contt.Id
left join BPMONline7.dbo.Contact ccont on ccont.Id=wo.UsrOwnerId
left join BPMONline7.dbo.SysAdminUnit ssau on ssau.ContactId = ccont.Id
where wod.Name like ''CRM%''')
                          AS derivedtbl_1
GO


