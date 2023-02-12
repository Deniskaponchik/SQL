USE BPMonline_SSC

Select 
	SC.Number [Номер обращения],
	UsrCaseSCRoute.Name [Направление],
	UsrBranchSC.Name [Компания],
	Accounting.name [Участок учёта],
	ServiceCategory.Name [Категория темы],
	ServiceItem.Name [Тема],
	UsrCaseSCStatus.Name [Статус],
	Contact.Name[Исполнитель],
	cmh.OldestComment [Дата комментария],
	cch.OldestStatus [Дата статуса],
	--sc.id,
	'http://sschotline.corp.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/UsrPortalCaseSCSCPage/edit/'+cast(SC.Id as nvarchar(64))

from UsrCaseSC sc
left join UsrCaseSCRoute on SC.RouteSCId = UsrCaseSCRoute.Id
left join UsrBranchSC on SC.UsrCompanyId = UsrBranchSC.ID
left join Accounting on SC.AccountingSCid = Accounting.Id                --Участок учёта
left join ServiceCategory on ServiceCategory.Id = SC.ServiceCategoryId   --Система
left join ServiceItem on ServiceItem.Id = SC.ServiceItemId               --Услуга
left join UsrCaseSCStatus on SC.StatusSCId = UsrCaseSCStatus.Id
left join Contact on Contact.Id = SC.OwnerID                             --Исполнитель
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
	  '020453A3-E21C-497F-9F50-3C4813B63B60'   -- В ОЦО
	, '018A5135-1743-4762-9F5B-04DA23613B73'   -- В Регион
	)
  AND cmh.OldestComment > dateadd(MINUTE,5,cch.OldestStatus)


ORDER BY sc.createdon
