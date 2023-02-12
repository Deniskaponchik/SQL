--v2.6
--СТАТУС: Работает корректно
--РЕАЛИЗАЦИЯ: Без Курсора + Временные таблицы + Убраны Макс, Мин, Дата перевода
--ПРОБЛЕМЫ: 

USE BPMonline_80;

drop table IF EXISTS #sr
drop table IF EXISTS #GroupTimeCii
drop table IF EXISTS #GroupTimeCii0
drop table IF EXISTS #GroupTimeCii1
drop table IF EXISTS #GroupTimeCii2
drop table IF EXISTS #cii0
drop table IF EXISTS #cii1
drop table IF EXISTS #cii2


--Таблица с необходимыми заявками, на которую в последствие ссылаются все остальные
	SELECT id, Number
	, dateadd(hh, +3, RegisteredOn) RegisteredOn
	, ServiceRequestTypeId, ServiceId, TechServiceId, StatusOfIncidentId
	, dateadd(hh, +3, SolutionDate) SolutionDate
	, SolutionOverdue
	, dateadd(hh, +3, ClosureDate) ClosureDate
	into #sr
	FROM ServiceRequest
    WHERE 
	--RegisteredOn >= dateadd(day,-1,getdate())
	--RegisteredOn > '2021-09-24 00:00:00' and RegisteredOn < '2021-09-24 23:59:59'
	--RegisteredOn BETWEEN '2021-09-24 00:00:00' and '2021-09-24 23:59:59'
	--RegisteredOn BETWEEN cast('2021-09-24' as datetime2) and cast('2021-09-25' as datetime2)

	  ClosureDate >= dateadd(day,-1,getdate())  --MAIN
	--ClosureDate > '2021-09-24 00:00:00' and ClosureDate < '2021-09-24 23:59:59' --FASTER
	--ClosureDate BETWEEN '2021-09-24 00:00:00' and '2021-09-24 23:59:59'
	--ClosureDate BETWEEN cast('2021-09-24' as datetime2) and cast('2021-09-25' as datetime2)
	--CONVERT(date,ClosureDate,101) = '2021-09-24'

	  and ServiceRequestTypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' --Тип обращения не NOC
	--ORDER BY id



SELECT 
   ServiceRequestId
--,OldGroupId
--,COALESCE(OldGroupId, 0) OldGroupId
--,ISNULL(OldGroupId) OldGroupId
  ,ISNULL(OldGroupId,'00000000-0000-0000-0000-000000000000')  OldGroupId
  ,NewGroupId,CreatedOn
--,cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int) AS NotChangingTime
  ,case
		when NotChangingTime = ''  then 0
		when NotChangingTime != '' then cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int)
   end AS NotChangingTime	
  ,OldStatusOfIncidentId 
into #cii0
FROM CounterInIncident
WHERE
  ServiceRequestId IN ( SELECT id FROM #SR )
--ServiceRequestId = 'D2E141DE-852C-46DD-B6AD-DDE5566C1556'
  and NewGroupId is not null



  SELECT ServiceRequestId, OldGroupId, SUM(NotChangingTime) as SumNotChangingTime
  into #cii1
  from #cii0
  where   --OldGroup IS NOT NULL
			OldStatusOfIncidentId NOT IN (
			 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
			,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
			,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
			)
			--or OldStatusOfIncidentId is NULL
		/*AND OldStatusOfIncidentId IN (
			 'F4BF3FB2-F36B-1410-109B-0050BA5D6C38' --В работе
			,'F6BE11BE-F36B-1410-109B-0050BA5D6C38' --Закрыта
			,'F5BF3FC4-F36B-1410-119B-0050BA5D6C38' --Новый
			,'B4BF30C8-F36B-1410-119B-0050BA5D6C38' --Отложенное решение
			,'F49E3FD2-F36B-1410-119B-0050BA5D6C38' --Решена
			,'92FE5FFE-60C4-4CCE-A0CC-8F6F2B3E3AB0' --Назначена на группу
			,'147213F8-47FB-40D3-8719-CBCAD5B7284A' --Назначена на сотрудника
			,'2D42FB9E-7F58-4DFC-954C-4EFDFFA51536' --Назначена на вендора
			,'1960D51E-40E5-4C3B-A9D6-843D2CA6BF68' --Отменена
			,'9D9C4CE1-2FE3-4DC7-A2E6-5DB6749B1076' --Позвонить
			,'92C1112E-FCCD-4C6F-9FC0-0BAE07FF8B87' --Позвонить на время
			,'DD7F55D2-7ACF-40E8-B9E7-25D630476838' --Тестирование
			,'2625827C-89FA-4D3A-93BB-3D1B01E324F3' --Ожидание информации
			,'2625827C-89FA-4D3A-93BB-3D1B01E324F4' --Позвонить еще
			, NULL
			)*/			
  GROUP BY ServiceRequestId, OldGroupID --NewGroupId
--ORDER BY ServiceRequestId



  SELECT ServiceRequestId, NewGroupId, COUNT(NewGroupID) as CountAssignGroup
  into #cii2
  from #cii0
  where OldGroupId <> NewGroupId
  GROUP BY ServiceRequestId, NewGroupID
--ORDER BY ServiceRequestId




SELECT
SR.Number AS 'Номер заявки'
,SOI.Name AS 'Статус'
,SR.RegisteredOn AS 'Дата регистрации'
,SRT.Name 'Тип обращения'
,S.ServiceName 'Сервис'
,Sc.ServiceName 'Краткое описание проблемы'
,SR.SolutionDate 'Срок решения'
,REPLACE(REPLACE(SR.SolutionOverdue, '0','нет'),'1','да') AS 'Просрочен'
,SumFullCII.SumFullNotChangingTime 'Общее время обработки (мин.)'
,GroupTimeCii.NewGroupID 'Группа'
,GroupTimeCii.SumNotChangingTime 'Время обработки группой (мин.)'
,GroupTimeCii.CountAssignGroup 'Кол-во назначений на группу'

FROM #sr sr
LEFT JOIN ServiceRequestType SRT WITH(NOLOCK) ON SRT.Id = SR.ServiceRequestTypeId
LEFT JOIN Service S WITH(NOLOCK) ON S.Id = SR.ServiceId
LEFT JOIN Service Sc WITH(NOLOCK) ON Sc.Id = SR.TechServiceId
LEFT JOIN StatusOfIncident SOI WITH(NOLOCK) ON SOI.Id = SR.StatusOfIncidentId

LEFT JOIN ( --'Общее время обработки (мин.)'
	SELECT ServiceRequestId, SUM(SumNotChangingTime) SumFullNotChangingTime
	FROM #cii1
	GROUP BY ServiceRequestId
	) SumFullCII ON sr.id = SumFullCII.ServiceRequestId

OUTER APPLY (
	SELECT
	  SAU.Name AS NewGroupID
	, SumNotChangingTime  
	, CountAssignGroup
	FROM
	#cii1 cii1
	left join #cii2 cii2 on cii1.ServiceRequestId = cii2.servicerequestid and cii1.OldGroupId = cii2.NewGroupId
	LEFT JOIN SysAdminUnit SAU WITH(NOLOCK) ON SAU.Id = Cii1.OldGroupId

	WHERE SR.id = cii1.ServiceRequestId

) GroupTimeCII

ORDER BY SR.Number



