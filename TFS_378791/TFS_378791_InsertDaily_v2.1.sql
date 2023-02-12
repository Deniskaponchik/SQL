--v2.1
--https://tfs.tele2.ru/tfs/Main/Tele2/_workitems/edit/385644
--ОПИСАНИЕ: Закрытые ЦК ПиР за вчера. Выгрузка с начала года
--СТАТУС: Рабочее
--РЕАЛИЗАЦИЯ: Связанные серверы. NotChangingTime считаю сам
--ПРОБЛЕМЫ: 

--USE ANALYTICSS;  USE BPMonline_80

--Declare @Date datetime2(3) = GetDate()  --Моё
--declare @start date = dateadd(dd,-1,dateadd(HH,3,getdate()));  --Константин
--declare @start date = cast('2022-01-01' as date);              --Константин
  declare @end   date = dateadd(HH,+3,getdate());                --Константин
--select @end

--WHILE (CONVERT(date,@Date,101) != '2022-01-01')  --Моё
--WHILE @end != '2022-01-01'  --Делать цикл, где сравнивается формат данных date и nvarchar можно, но не коррекно
--WHILE (@start != @end)      --Константин

--BEGIN
	--SET @Date = dateadd(day,-1,@Date)  --Моё
	--select @end

	drop table IF EXISTS #sr
	drop table IF EXISTS #cii0
	drop table IF EXISTS #cii00
	drop table IF EXISTS #cii1
	drop table IF EXISTS #cii2

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
		--ClosureDate >= dateadd(day,-1,getdate())
		--ClosureDate >= @Date  --MAIN моё
		--dateadd(HH,3,ClosureDate) >= @start  --Константин
		--ClosureDate > '2022-01-01 00:00:00' and ClosureDate < '2022-10-24 23:59:59' --FASTER

		--ClosureDate BETWEEN '2022-11-08 00:00:00' and '2022-11-08 23:59:59'
		  ClosureDate BETWEEN '2021-09-23 00:00:00' and '2021-09-23 23:59:59'
		--dateadd(HH,3,ClosureDate) BETWEEN @start and @end  --
		--dateadd(HH,3,ClosureDate) between @start and DATEADD(DD,1,@start) --чтобы не опираться на 2 переменные
		--dateadd(HH,3,ClosureDate) between DATEADD(DD,1,@end) and @end --чтобы не опираться на 2 переменные
		--dateadd(HH,3,ClosureDate) between DATEADD(HH,27,ClosureDate) and dateadd(HH,+3,getdate()) --чтобы не опираться на 2 переменные
		--ClosureDate BETWEEN cast('2021-09-24' as datetime2) and cast('2021-09-25' as datetime2)
		--CONVERT(date,ClosureDate,101) = '2021-09-24'

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
			,'624A3A8E-FB29-E411-80BC-00155DFC1F77' --Проблемы с платежами
			,'644A3A8E-FB29-E411-80BC-00155DFC1F77' --Сервисы
			,'53DA01DF-7DBA-463D-B5C8-46F556973A18' --Сервисы
			,'45CDCB85-A4B6-47F2-981B-9EE13CD5CF3D' --Тарификация
			,'80CCF889-F16B-4FB4-872D-63AB17FA6670' --Тарификация
			,'664A3A8E-FB29-E411-80BC-00155DFC1F77' --Тарификация
			,'5F72F2EB-3839-44A9-B475-E105C469DF48' --Тарификация
			,'E280187B-E873-474E-AEA2-EB5B60D05787' --Тарификация
			,'0F0C9CBA-8988-44EE-8ABA-604375171915' --Тарификация
			,'80B31720-41A9-468B-970F-0F74596DC1C4' --Телефония
			,'674A3A8E-FB29-E411-80BC-00155DFC1F77' --Телефония
			,'6BB86A4F-61D1-478A-83CE-3F3D4F41ABE1' --Телефония
			,'3F53E88E-914B-4D95-9D57-E0F721A03585' --Телефония (MVNO)
			,'89C2B29D-4064-41B7-A9A4-74045FDF1CEF' --Умный ноль
			,'7D73409B-0486-4914-A926-D5BC09F2AC50' --Billing - Сверка
			,'4B4A3A8E-FB29-E411-80BC-00155DFC1F77' --MNP
			,'4B4A3A8E-FB29-E411-80BC-00155DFC1F77' --MNP
			,'4B4A3A8E-FB29-E411-80BC-00155DFC1F77' --MNP
			,'D191ACD0-19FD-E311-8D19-001999B0E1E0' --Observation
			,'3C01DA6E-2C04-41BF-A5E6-32CB5043BA18' --Partners
			,'229B06DD-6E12-44D2-8222-431AA505026E' --Partners
			,'0E506823-5B39-4A6A-B6D1-48F444B2D9D5' --Partners
			,'64999A0A-A771-469A-8203-5D2D1F536711' --Partners
			,'4C4A3A8E-FB29-E411-80BC-00155DFC1F77' --RBT-Гудок
			,'9B7B69B4-9CDF-48DD-BAF0-39ED26900874' --RBT-Гудок
			,'CFAF420B-E50C-E411-8D19-001999B0E1E0' --SMS
			,'D0AF420B-E50C-E411-8D19-001999B0E1E0' --SMS
			,'D1AF420B-E50C-E411-8D19-001999B0E1E0' --SMS
			,'DB4A3A8E-FB29-E411-80BC-00155DFC1F77' --SMS
			,'8E54F9FA-E10C-E411-8D19-001999B0E1E0' --SMS
			,'38274E85-2A58-48B2-A7FB-3E43E5738536' --SMS
			,'3CAE893D-4D81-4868-A70B-4C5AA732FDB2' --SMS
			,'4D9513AE-4FAB-4C86-A615-8E6925E17310' --SMS
			,'4D4A3A8E-FB29-E411-80BC-00155DFC1F77' --SMS
			,'9EE755BB-D226-4FA2-9BC5-397D319B20A9' --SMS нотификации от компании Теле2
			,'A71D9A66-D66F-4496-A21B-7FADC26C9ABE' --SMS (MVNO)
			,'D791ACD0-19FD-E311-8D19-001999B0E1E0' --USSD
			,'02C0A7E5-44DF-4A30-B7AC-9F4E550B8E6D' --USSD
			,'4E4A3A8E-FB29-E411-80BC-00155DFC1F77' --USSD
			,'55C61BA5-EC8A-40E6-9FE0-E61A496B558E' --Wink
		  )
		--ORDER BY id



	--Базовая полная таблица счётчиков со всеми значениями, которую потом будут фильтровать другие #cii№
	SELECT 
	   ServiceRequestId
	  ,ISNULL(OldGroupId,'00000000-0000-0000-0000-000000000000')  OldGroupId
	  ,NewGroupId
	  ,CreatedOn --Время уже московское в поле
	  /*,case --Закоментировать отсюда
		when NotChangingTime = ''  then 0
		when NotChangingTime != '' then cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int)
	   end AS NotChangingTime */
	into #cii00    --Закоментировать досюда
	--FROM [BPMonline_80].[dbo].[CounterInIncident]
	FROM [T2RU-BPMDB-05\BPMONLINE].[BPMonline].[dbo].[CounterInIncident]
	WHERE
	  ServiceRequestId IN ( SELECT id FROM #SR )
	--ServiceRequestId = 'D2E141DE-852C-46DD-B6AD-DDE5566C1556'
	  and NewGroupId is not null


	  	--Базовая полная таблица счётчиков со всеми значениями, которую потом будут фильтровать другие #cii№
	SELECT 
	   cii1.ServiceRequestId ServiceRequestId
	  ,cii1.OldGroupId OldGroupId
	  ,cii1.NewGroupId NewGroupId
	  ,cii1.CreatedOn CreatedOn --Время уже московское в поле
	  --,cii1.NotChangingTime -- COMMENT
	  --,DATEDIFF(minute, cii2.CreatedOn, cii1.CreatedOn) AS NotChangingTimeMy
	  ,ISNULL(DATEDIFF(minute, cii2.CreatedOn, cii1.CreatedOn), 0) AS NotChangingTime
	  into #cii0
	--FROM [BPMonline_80].[dbo].[CounterInIncident]
	FROM (
		SELECT row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
		,ServiceRequestId ,OldGroupId ,NewGroupId ,CreatedOn --,NotChangingTime 
		FROM #cii00
	) cii1
	left join ( --БУДУЩАЯ строка
		SELECT 1+row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
		,ServiceRequestId ,CreatedOn
		FROM #cii00
	) cii2 ON cii1.RowNumber = cii2.RowNumber AND cii1.ServiceRequestId = cii2.ServiceRequestId


	--Select * from #cii0





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
	--LEFT JOIN Service S WITH(NOLOCK) ON S.Id = SR.ServiceId
	--LEFT JOIN Service Sc WITH(NOLOCK) ON Sc.Id = SR.TechServiceId
	--LEFT JOIN ServicePriorityForSR spfsr on spfsr.id = sr.ServicePriorityId
	LEFT JOIN [T2RU-BPMDB-05\BPMONLINE].[BPMonline].[dbo].[Service] S WITH(NOLOCK) ON S.Id = SR.ServiceId
	LEFT JOIN [T2RU-BPMDB-05\BPMONLINE].[BPMonline].[dbo].[Service] Sc WITH(NOLOCK) ON Sc.Id = SR.TechServiceId
	LEFT JOIN [T2RU-BPMDB-05\BPMONLINE].[BPMonline].[dbo].[ServicePriorityForSR] spfsr on spfsr.id = sr.ServicePriorityId
	right join #cii1 cii1 on cii1.ServiceRequestId = sr.Id
	right join #cii2 cii2 on cii2.ServiceRequestId = sr.Id

	--ORDER BY SR.Number
	--order by SR.ClosureDate

    --SET @start = dateadd(day,1,@start)  --Константин
	--SET @End   = dateadd(day,1,@end)    --Моё


--END  -- End of Loop
