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
	cch.OldestStatus [���� �������],
	--sc.id,
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
	  --, dateadd(MINUTE,185,MAX(UsrChangedStatusDate)) OldestStatus
	  --, cast((dateadd(MINUTE,185,MAX(UsrChangedStatusDate))) as smalldatetime) OldestStatus
		, cast((dateadd(HOUR,3,MAX(UsrChangedStatusDate))) as smalldatetime) OldestStatus
	from UsrCaseChangesHistory h1
	where h1.UsrCaseSCId = SC.id
	group by UsrCaseSCId
	) cch
outer apply (
	select UsrCaseSCId
	  --, dateadd(HOUR,3,MAX(CreatedOn)) OldestComment
	    , cast((dateadd(HOUR,3,MAX(CreatedOn))) as smalldatetime) OldestComment
	from UsrCaseSCMessageHistory h2
	where h2.UsrCaseSCId = SC.id
	  and h2.MessageNotifierId = '0C61DA8A-7A29-42C0-9877-08D5FEF15F28'  --Portal
	group by UsrCaseSCId
	) cmh

where SC.RouteSCId IN (
	  '020453A3-E21C-497F-9F50-3C4813B63B60'   -- � ���
	, '018A5135-1743-4762-9F5B-04DA23613B73'   -- � ������
	)
  AND cmh.OldestComment > dateadd(MINUTE,5,cch.OldestStatus)


ORDER BY sc.createdon
