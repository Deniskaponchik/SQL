--USE [ANALYTICSS]
USE BPMonline7_14880

/*GO
Object:  View [dbo].[VwBPMWO_Executor_Personal_All_4CRM]    Script Date: 05.04.2022 10:05:00 --��� ������ ���� ����������������
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[VwBPMWO_Executor_Personal_All_4CRM]
AS
SELECT  *
FROM            OPENROWSET('SQLNCLI', 'Server=t2ru-bpmdb-read\BPMOnline;UID=helper;PWD=b4vax;', '*/

Select 
						 wo.UsrNumber [�����_WA],
						 wo.Id[ID_number],
						 Executors.FIO [�����������_(���)],
						 Executors.samaccountname [�����������_UID_(samaccountname)],
						 wos.Name[���������_(���)],
						 wot.name[���_�����_(���)],
						 bd.Name[������� �������� (���)],
						 wod.Name[����������� (���)],
						 wod.Id[����������� (GUID)],
						 wo.UsrDescription[�������� (�����)],
						 contt.name[����� (���)],
						 sauu.Name[����� UID (samaccountname)],
						 ccont.Name[������������� (���)],
						 ssau.Name[������������� UID (samaccountname)],
						 dateadd(HOUR,3,wo.UsrPlannedTimeStart)[����������� ������ (����/�����)],
						 dateadd(HOUR,3,wo.UsrPlannedTimeEnd)[����������� ��������� (����/�����)],
						 dateadd(HOUR,3,wo.UsrFactStartDate)[����������� ������ (����/�����)],
						 dateadd(HOUR,3,wo.UsrFactEndDate)[����������� ��������� (����/�����)],
						 dateadd(HOUR,3,Wo.ModifiedOn)[���� ��������� (����/�����)]

     from /*BPMONline7.dbo.*/UsrWorkOrder WO
left join /*BPMONline7.dbo.*/UsrWOStatus wos on wos.Id=wo.UsrWOStatusId
left join /*BPMONline7.dbo.*/UsrWOType wot on wot.id=wo.UsrWOTypeId
left join /*BPMONline7.dbo.*/UsrBriefDescription bd on bd.id=wo.UsrShortDescriptionId
left join /*BPMONline7.dbo.*/UsrWODestination wod on wod.Id=wo.UsrWODestinationId
left join /*BPMONline7.dbo.*/Contact contt on contt.Id=wo.UsrAuthorId
left join /*BPMONline7.dbo.*/SysAdminUnit sauu on sauu.ContactId = contt.Id
left join /*BPMONline7.dbo.*/Contact ccont on ccont.Id=wo.UsrOwnerId
left join /*BPMONline7.dbo.*/SysAdminUnit ssau on ssau.ContactId = ccont.Id

OUTER APPLY ( --������������ ������ ��������� ��������� ����� WA+�����������, �.�. �� ������� ����������� � ������ 1 ������ ��������� ������ � �������������.
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


