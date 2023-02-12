-- v0.8
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
	dateadd(MINUTE,-5,cch.OldestStatus) [Дата статуса],
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
		, dateadd(MINUTE,185,MAX(CreatedOn)) OldestStatus
	from UsrAudit h1
	where h1.UsrCaseSCId = SC.id 
	  and UsrColumn = 'Статус'    --В Таблице UsrAudit нет id для этого Поля
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
	  '020453A3-E21C-497F-9F50-3C4813B63B60'   -- В ОЦО
	, '018A5135-1743-4762-9F5B-04DA23613B73'   -- В Регион
	)
  and UsrCaseSCRoute.Name in (@somevar) */

  AND cmh.OldestComment > cch.OldestStatus
  and cmh.OldestComment between (@start) and dateadd(day,1,(@end))
  --and cmh.OldestComment between cast('2022-01-01' as date) and cast('2022-05-24' as date)

  and cmh.CreatedById <> sc.OwnerId            --Автор последнего комментария <> Исполнитель
  

  
ORDER BY sc.createdon
