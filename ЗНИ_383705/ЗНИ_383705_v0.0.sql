--v0.0
--https://tfs.tele2.ru/tfs/Main/Tele2/_workitems/edit/383705
--ОПИСАНИЕ: 
--СТАТУС: 
--РЕАЛИЗАЦИЯ: 
--ПРОБЛЕМЫ: 

--USE ANALYTICSS;
SELECT TOP (1000) [Id]
      ,[CreatedOn]
      ,[Number]
      ,[RegisteredOn]
      ,[Subject]
      ,[Symptoms]
      ,[OwnerId]
      ,[ResponseDate]
      ,[SolutionDate]
      ,[StatusId]
      ,[Notes]
      ,[PriorityId]
      ,[OriginId]
      ,[AccountId]
      ,[ContactId]
      ,[GroupId]
      ,[RespondedOn]
      ,[SolutionProvidedOn]
      ,[ClosureDate]
      ,[ClosureCodeId]
      ,[Solution]
      ,[SatisfactionLevelId]
      ,[CategoryId]
      ,[ResponseOverdue]
      ,[SolutionOverdue]
      ,[SatisfactionLevelComment]
      ,[SolutionRemains]
      ,[ServicePactId]
      ,[ServiceItemId]
      ,[SupportLevelId]
      ,[SolvedOnSupportLevelId]
      ,[ParentCaseId]
      ,[ProblemId]
      ,[ChangeId]
      ,[ServiceCategoryId]
      ,[FirstSolutionProvidedOn]
      ,[UsrTimeLimit]
      ,[UsrDecisionPostponed]
      ,[UsrPostponedTime]
      ,[UsrRegionId]
      ,[UsrAuthorId]
      ,[UsrChangedContactId]
      ,[UsrChangedData]
      ,[UsrResolvedGroupId]
      ,[UsrResolvedContactId]
      ,[UsrClosedContactId]
      ,[UsrMacroregionId]
      ,[UsrSystemId]
      ,[UsrTimeZone]
      ,[UsrConfidentially]
      ,[UsrCurrentVisaOrder]
      ,[UsrIsVisasImportedFromSI]
      ,[UsrIsFinalComment]
      ,[UsrCaseHandlingTime]
      ,[UsrCaseStatusChanged]
      ,[UsrStageId]
      ,[UsrExpertReviewDone]
      ,[UsrPreviousStageId]
      ,[UsrSequence]
      ,[ParametersDescription5X]
      ,[Id5X]
      ,[UsrPreparationCompleted]
      ,[UsrIsClarified]
      ,[UsrParametersSet]
      ,[UsrParametersAdded]
      ,[UsrScriptId]
      ,[UsrIsScriptExecuted]
      ,[UsrSolvedGroupId]
      ,[UsrIsGroupAwaitNotification]
      ,[UsrIsGroupNotified]
      ,[UsrWasClarified]
      ,[UsrIsActive]
      ,[UsrPauseDate]
      ,[UsrPausePeriod]
      ,[UsrSolutionDateBeforePause]
      ,[UsrClarifiedGroupId]
      ,[UsrDevRequest]
      ,[UsrErrorCategoryId]
      ,[ConfItemId]
      ,[HolderId]
      ,[ProcessingTimeUnitId]
      ,[ProcessingTimeUnitValue]
      ,[ParentActivityId]
      ,[BnzScriptExecId]
  FROM [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[Case]
  where Number = 'SR06476964'



  SELECT TOP (1000) [Id]
      ,[StringValue]
      ,[IntValue]
      ,[FloatValue]
      ,[BooleanValue]
      ,[ListItemValueId]
      ,[SpecificationId]
      ,[UsrLookupValue]
      ,[UsrLookupValueText]
      ,[UsrMultilineTextValue]
      ,[UsrCaseId]
      ,[UsrIsRequired]
      ,[UsrIsAfterEffect]
      ,[UsrOrderPosition]
      ,[UsrMultiLookupValue]
      ,[UsrMultiLookupValueText]
      ,[UsrDescription]
      ,[UsrDateValue]
      ,[UsrDateTimeValue]
      ,[UsrMessageValue]
      ,[UsrRegExp]
  FROM [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrSpecificationInCase]
  where UsrCaseId = ''


  --Параметр в Перечне параметров
  SELECT TOP (1000) [Id]
      ,[TypeId]
      ,[Description]
      ,[UsrLookupId]
      ,[UsrIsRequired]
      ,[UsrHint]
      ,[UsrIsAfterEffect]
      ,[Name]
  FROM [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrSpecification]
  --where Id = '6EF5D492-E030-4C55-85F2-43CF7F279F60' --Параметр Мобильный телефон пользователя
  --where Id = 'A1D0C8C3-EB31-4671-A922-C97E437C3591' --Параметр Адрес офиса
  --where Id = '28BBDCC4-ED50-4BCD-AC06-EEEA667D62AC' --Параметр Обоснование запроса
  --where Id = '5C8DEE23-E48A-45BC-A084-573E1A6CC5CA' --Параметр Регион
  --where Id = 'F01F84BE-B8F1-454F-A947-2C7F832BBB88' --Параметр Мониторинг
  --where Id = 'F01F84BE-B8F1-454F-A947-2C7F832BBB88' --Параметр Логин пользователя
  --where Id = '3E5E9091-D22A-43F2-B4BD-42F791CA1DC5' --Параметр ФИО пользователя
  --where Id = 'BDE054E7-2B91-41C1-ABBA-2DCBE3A8F3F4' --Параметр Вид инцидента
  where Id = '69f30120-1375-447b-bce3-82197bbb3e70' --Параметр Месторасположение



  --Справочник в Параметре в Перечне параметров
  SELECT TOP (1000) [Id]
      ,[ProcessListeners]
      ,[Name]
      ,[Description]
      ,[SysEntitySchemaUId]
      ,[SysPageSchemaUId]
      ,[SysLookupId]
  FROM [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[Lookup]
  where id = '9957AB2C-A353-49BF-A6EB-9968966C4BE8'  --Справочник UsrHelpDeskRegion


  --Наполнение справочника UsrHelpDeskRegion
    SELECT TOP (1000) [Id]
      ,[UsrVisaRolesId]
      --,[UsrLookupId]
      --,[UsrServiceItemId]
      ,[UsrLookupValueGuid]
      ,[UsrLookupValueName]
      --,[UsrRegionCodes]
      --,[UsrName]
  FROM [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrVisa]
  where UsrLookupId = '9957AB2C-A353-49BF-A6EB-9968966C4BE8'
  and UsrServiceItemId = 'ED84A37F-4B31-4DAB-85FE-BA4FE87325B1'
  order by UsrLookupValueName











	--Таблица с необходимыми заявками, на которую в последствие ссылаются все остальные
		SELECT id
		, Number
		, dateadd(hh,+3,ClosureDate) ClosureDate
		, ServiceId, TechServiceId
		, ServicePriorityId
		,case 
			when ServicePriorityId = 'D05B9A45-7398-48A5-8358-87FBE7E2DBA8' then 780   --0
			when ServicePriorityId = '1A404A71-5FB5-4EFC-A849-5EADF5BCEC11' then 780   --1
			when ServicePriorityId = '073FE74E-93CF-435F-8CE7-61F5523F5C6C' then 960   --2
			when ServicePriorityId = 'D744C596-CC9B-42AF-A3B6-5A4EC9FB7AB9' then 1440  --3
			when ServicePriorityId = '659D7CB1-82EA-4A4F-8B6C-5281A3E290E2' then 2160  --4
			when ServicePriorityId = '0985F708-42D6-4669-A389-B0605BDD7338' then 2880  --5
			when ServicePriorityId = '5F695C37-9B23-4685-BAB8-6EE313457BB1' then 2880  --6
		 end SLA_Time_minutes
		into #sr
		--FROM [BPMonline_80].[dbo].[ServiceRequest]
		FROM [T2RU-BPMDB-05\BPMONLINE].[BPMonline].[dbo].[ServiceRequest]

		WHERE 
		--ClosureDate > '2022-01-01 00:00:00' and ClosureDate < '2022-10-24 23:59:59' --FASTER
		--ClosureDate BETWEEN '2022-10-23 00:00:00' and '2022-10-23 23:59:59
		  ClosureDate BETWEEN @start and @end  --Работает БЫСТРО
		--ClosureDate BETWEEN @start and DATEADD(DD,1,@start) -- Отрабатывает МЕДЛЕННЕЕ

		--dateadd(HH,3,ClosureDate) >= @start  --Константин
		--dateadd(HH,3,ClosureDate) BETWEEN @start and @end  --MAIN
		--dateadd(HH,3,ClosureDate) between @start and DATEADD(DD,1,@start) --чтобы не опираться на 2 переменные

		  and ServiceId in (
			 'FFA96B25-ACC0-4B24-81C9-F141002D9C74' --Администрирование B2B
			,'514A3A8E-FB29-E411-80BC-00155DFC1F77' --Администрирование B2B
			,'9D17176D-4637-4B83-A510-4021AD3F432D' --Бизнес смс
			,'27589F21-FA6E-4FE4-A214-FA6B56CCD265' --Выгодно вместе
			,'D03797DF-377B-466B-AAA1-DAFEC7AA8696' --Выделенный APN/Мобильный VPN
			,'544A3A8E-FB29-E411-80BC-00155DFC1F77' --ГПЯ
			,'8F53AFC7-1417-44EC-96AD-42D4E8E4BF6E' --Единый счет
			,'CFF2624E-674F-44F4-A9F7-D6789E97ABE4' --Единый счет
			,'A20FD0B6-433E-4381-82EF-7DABBCECD213' --Единый счет
			,'11059BD4-70F0-4AFE-9163-87D78B6AFE4D' --Интернет магазин
			,'584A3A8E-FB29-E411-80BC-00155DFC1F77' --Контент
			,'A91D00B4-E793-4F0E-AD3E-70EACD975162' --Корпоративная АТС
			,'8DB418BE-3E5B-4A54-9D04-9D896E1E1703' --Мобильные переводы и оплата
			,'5C4A3A8E-FB29-E411-80BC-00155DFC1F77' --Мошенничество
			,'AF4A3A8E-FB29-E411-80BC-00155DFC1F77' --Мошенничество
			,'D787D6C4-FC32-4DDE-BAB4-84B6ACE4E011' --Мошенничество
			,'29999861-7081-4E9B-83FA-64A590BF182B' --Одобрение ЭРФ
			,'C030702C-32C7-438C-9E64-F024EF281994' --Приветственная SMS в роуминге (WSMS)
			,'65112F90-56DE-4852-A29D-A9A1571BFA54' --Проблема с SPR
		  )
		--ORDER BY id



	--Базовая полная таблица счётчиков со всеми значениями, которую потом будут фильтровать другие #cii№
	SELECT 
	   ServiceRequestId
	  ,ISNULL(OldGroupId,'00000000-0000-0000-0000-000000000000')  OldGroupId
	  ,NewGroupId
	  ,CreatedOn --Время уже московское в поле
	  ,case
		when NotChangingTime = ''  then 0
		when NotChangingTime != '' then cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int)
	   end AS NotChangingTime
	into #cii0
	--FROM [BPMonline_80].[dbo].[CounterInIncident]
	FROM [T2RU-BPMDB-05\BPMONLINE].[BPMonline].[dbo].[CounterInIncident]
	WHERE
	  ServiceRequestId IN ( SELECT id FROM #SR )
	--ServiceRequestId = 'D2E141DE-852C-46DD-B6AD-DDE5566C1556'
	  and NewGroupId is not null



	--Группировка по СТАРОМУ значению группы
	SELECT ServiceRequestId, MAX(MaxCreatedOn) as Last_reAssign, SUM(SumNotChangingTime) as Fact_work_time_minutes
	into #cii1
	From (
	  SELECT ServiceRequestId, OldGroupId, MAX(CreatedOn) as MaxCreatedOn, SUM(NotChangingTime) SumNotChangingTime
	  from #cii0
	  where  OldGroupId IN (
		 'C0FF797E-1469-4D5B-ADF3-320F99F9EB97' --Billing GSC
		,'849C5EB4-FA8D-4B9D-A5C6-D6E57E5849F9' --Billing Support
		,'E8834B81-2CB2-43DD-A6EA-0612FDD36503' --Billing Roaming
		,'7CB251DE-7DDB-4BFC-9558-0104D1DB28C5' --VAS Customer Services
		,'E3EEA783-D1CF-48C4-AE05-8E3127C05556' --VAS Voice Services
		,'212A31DD-9D3D-422D-9C49-93024B2CD314' --VAS Service Platform
		)	
	  GROUP BY ServiceRequestId, OldGroupID
	--ORDER BY ServiceRequestId
	) cii11
	Group by ServiceRequestId



	--Группировка по НОВОМУ значению группы
	SELECT ServiceRequestId, MIN(MinCreatedOn) as First_Assign
	into #cii2
	FROM (
	  SELECT ServiceRequestId, NewGroupId, MIN(CreatedOn) as MinCreatedOn
	  from #cii0
	  where NewGroupId IN (
		 'C0FF797E-1469-4D5B-ADF3-320F99F9EB97' --Billing GSC
		,'849C5EB4-FA8D-4B9D-A5C6-D6E57E5849F9' --Billing Support
		,'E8834B81-2CB2-43DD-A6EA-0612FDD36503' --Billing Roaming
		,'7CB251DE-7DDB-4BFC-9558-0104D1DB28C5' --VAS Customer Services
		,'E3EEA783-D1CF-48C4-AE05-8E3127C05556' --VAS Voice Services
		,'212A31DD-9D3D-422D-9C49-93024B2CD314' --VAS Service Platform
		)
	  GROUP BY ServiceRequestId, NewGroupID
	--ORDER BY ServiceRequestId
	) cii22
	Group by ServiceRequestId



	--insert into BPM5_SLA_TFS360841_4PiR --(TT, Close_Date, Service, KOP, Priority, SLA_Time_minutes, First_Assign, Last_reAssign, Fact_work_time_minutes, SLA_delta_minutes)
	SELECT
	 SR.Number AS 'TT'
	,SR.ClosureDate AS 'Close_Date'
	,S.ServiceName 'Service'
	,Sc.ServiceName 'KOP'
	,spfsr.Name 'Priority'
	,sr.SLA_Time_minutes 'SLA_Time_minutes'
	,cii2.First_Assign 'First_Assign'
	,cii1.Last_reAssign 'Last_reAssign'
	,cii1.Fact_work_time_minutes 'Fact_work_time_minutes'
	,SR.Sla_Time_minutes - cii1.Fact_work_time_minutes 'SLA_delta_minutes'

	FROM #sr sr
	LEFT JOIN [T2RU-BPMDB-05\BPMONLINE].[BPMonline].[dbo].[Service] S WITH(NOLOCK) ON S.Id = SR.ServiceId
	LEFT JOIN [T2RU-BPMDB-05\BPMONLINE].[BPMonline].[dbo].[Service] Sc WITH(NOLOCK) ON Sc.Id = SR.TechServiceId
	LEFT JOIN [T2RU-BPMDB-05\BPMONLINE].[BPMonline].[dbo].[ServicePriorityForSR] spfsr on spfsr.id = sr.ServicePriorityId
	right join #cii1 cii1 on cii1.ServiceRequestId = sr.Id
	right join #cii2 cii2 on cii2.ServiceRequestId = sr.Id
