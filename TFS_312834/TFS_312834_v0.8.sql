-- v0.8
USE BPMonline_SSC

Select 
	SC.Number [����� ���������],
    UsrCaseSCRoute.Name [�����������],
	UsrBranchSC.Name [��������],
	Accounting.name [������� �����],
	ServiceCategory.Name [��������� ����],
	ServiceItem.Name [����],
	UsrCaseSCStatus.Name [������],
	Contact.Name[�����������],
	cmh.OldestComment [���� �����������],
	dateadd(MINUTE,-5,cch.OldestStatus) [���� �������],
	'http://sschotline.corp.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/UsrPortalCaseSCSCPage/edit/'+cast(SC.Id as nvarchar(64))

from UsrCaseSC sc
left join UsrCaseSCRoute on SC.RouteSCId = UsrCaseSCRoute.Id
left join UsrBranchSC on SC.UsrCompanyId = UsrBranchSC.ID
left join Accounting on SC.AccountingSCid = Accounting.Id                --������� �����
left join ServiceCategory on ServiceCategory.Id = SC.ServiceCategoryId   --�������
left join ServiceItem on ServiceItem.Id = SC.ServiceItemId               --������
left join UsrCaseSCStatus on SC.StatusSCId = UsrCaseSCStatus.Id
left join Contact on Contact.Id = SC.OwnerID                             --�����������
outer apply (
	select UsrCaseSCId
		, dateadd(MINUTE,185,MAX(CreatedOn)) OldestStatus
	from UsrAudit h1
	where h1.UsrCaseSCId = SC.id 
	  and UsrColumn = '������'    --� ������� UsrAudit ��� id ��� ����� ����
	group by UsrCaseSCId
	) cch

/*outer apply (
	select UsrCaseSCId
	    , dateadd(HOUR,3,MAX(CreatedOn)) OldestComment
	  --, cast((dateadd(HOUR,3,MAX(CreatedOn))) as smalldatetime) OldestComment
	from UsrCaseSCMessageHistory h2
	where h2.UsrCaseSCId = SC.id
	  and h2.MessageNotifierId = '0C61DA8A-7A29-42C0-9877-08D5FEF15F28'  --Portal
	group by UsrCaseSCId
	) cmh */
outer apply (
	select CreatedById, dateadd(HOUR,3,CreatedOn) OldestComment
	From  UsrCaseSCMessageHistory
	where CreatedOn = (
		select MAX(CreatedOn)
		from UsrCaseSCMessageHistory
		where UsrCaseSCId = SC.id
		  and MessageNotifierId != 'D6650C53-BBE4-4AC2-9DF8-A1FD23938E83'
		group by UsrCaseSCId
	)
 ) cmh

where 
	  SC.RouteSCId IN (@somevar)
/*    SC.RouteSCId IN (
	  '020453A3-E21C-497F-9F50-3C4813B63B60'   -- � ���
	, '018A5135-1743-4762-9F5B-04DA23613B73'   -- � ������
	)
  and UsrCaseSCRoute.Name in (@somevar) */

  AND cmh.OldestComment > cch.OldestStatus
  and cmh.OldestComment between (@start) and dateadd(day,1,(@end))
  --and cmh.OldestComment between cast('2022-01-01' as date) and cast('2022-05-24' as date)

  and cmh.CreatedById <> sc.OwnerId            --����� ���������� ����������� <> �����������
  

  
ORDER BY sc.createdon
