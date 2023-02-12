--REGISTERED ON LAST DAY
USE BPMonline_80;

Declare @SR Table(
Id	uniqueidentifier,
Number	nvarchar(250),
RegisteredOn	datetime2(3),
ServiceRequestTypeId	uniqueidentifier,
ServiceId	uniqueidentifier,
TechServiceId	uniqueidentifier,
StatusOfIncidentId	uniqueidentifier,
SolutionDate	datetime2(3),
SolutionOverdue	bit,
ClosureDate	datetime2(3)
);

Declare @GroupTimeCii0 Table(
ServiceRequestId	uniqueidentifier,
OldGroupId	uniqueidentifier,
MaxCreatedOn	datetime2(3)
);

Declare @GroupTimeCii1 Table(
ServiceRequestId	uniqueidentifier,
OldGroupId	uniqueidentifier,
MaxCreatedOn	datetime2(3)
);

Declare @GroupTimeCii2 Table(
ServiceRequestId	uniqueidentifier,
OldGroupId	uniqueidentifier,
MaxNotChangingTime int,
MinNotChangingTime int,
SumNotChangingTime int
);

--Таблица с необходимыми заявками, на которую в последствие ссылаются все остальные
INSERT INTO @SR (id, Number, RegisteredOn, ServiceRequestTypeId, ServiceId, TechServiceId, StatusOfIncidentId, SolutionDate, SolutionOverdue, ClosureDate)
	SELECT id, Number
	, dateadd(hh, +3, RegisteredOn) RegisteredOn
	, ServiceRequestTypeId, ServiceId, TechServiceId, StatusOfIncidentId
	, dateadd(hh, +3, SolutionDate) SolutionDate
	, SolutionOverdue
	, dateadd(hh, +3, ClosureDate) ClosureDate
	FROM ServiceRequest
    WHERE ServiceRequestTypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' --Тип обращения не NOC
	--and RegisteredOn >= dateadd(day,-1,getdate())
	and RegisteredOn > '2021-09-23 00:00:00' and RegisteredOn < '2021-09-23 23:59:59'
	--and ClosureDate >= dateadd(day,-1,getdate())

Declare @CII0 Table(
OldGroupId	uniqueidentifier,
NewGroupId	uniqueidentifier,
NewStatusOfIncidentId	uniqueidentifier,
CreatedOn	datetime2(3),
NotChangingTime	int,
ServiceRequestId	uniqueidentifier
);

Declare @CII Table(
OldGroupId	uniqueidentifier,
NewGroupId	uniqueidentifier,
NewStatusOfIncidentId	uniqueidentifier,
CreatedOn	datetime2(3),
RightNotChangingTime	int,
ServiceRequestId	uniqueidentifier
);

--Урезанная под определённые условия CounterInIncident
INSERT INTO @CII0 (OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn,NotChangingTime,ServiceRequestId)
	SELECT OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn
	,cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int) AS NotChangingTime
	,ServiceRequestId
	FROM CounterInIncident
	WHERE
		ServiceRequestId IN ( SELECT id FROM @SR )
	    --ServiceRequestId = 'A4D05827-F5AC-416C-9BD5-DF21C8750ACD'
		AND NotChangingTime != ''
		/* В полях Общее время обработки (мин.), Максимальное время обработки группой (мин.), Минимальное время обработки группой (мин.), Время обработки группой (мин.) 
	    не должны участвовать значения, у которых "Новое значение статуса" во вкладке счетчики равно “Внешний запрос”, “Внутренний запрос” или “Возвращена на доработку */
		AND NewStatusOfIncidentId NOT IN (
			 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
			,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
			,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
			)

--Выборка из Cii0 нужными заявками. CounterInIncident скрещивается с самой собой с полями -1
INSERT INTO @CII (OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn,RightNotChangingTime,ServiceRequestId)
SELECT cii1.OldGroupId,cii1.NewGroupId,cii1.NewStatusOfIncidentId,cii1.CreatedOn 
--	,cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int)
  ,case --джойним ПРОШЛУЮ, НАСТОЯЩУЮ и БУДУЩУЮ строки
when cii0.OldGroupId IS NULL AND cii1.OldGroupId = cii1.NewGroupId AND cii2.OldGroupId IS NULL then cii1.NotChangingTime
when cii0.OldGroupId IS NULL AND cii1.OldGroupId = cii1.NewGroupId AND cii2.OldGroupId <> cii2.NewGroupId then NULL
when cii0.OldGroupId IS NULL AND cii1.OldGroupId = cii1.NewGroupId AND cii2.OldGroupId = cii2.NewGroupId then NULL
when cii0.OldGroupId = cii0.NewGroupId AND cii1.OldGroupId <> cii1.NewGroupId AND cii2.OldGroupId <> cii2.NewGroupId then cii0.NotChangingTime + cii1.NotChangingTime
when cii0.OldGroupId = cii0.NewGroupId AND cii1.OldGroupId <> cii1.NewGroupId AND cii2.OldGroupId = cii2.NewGroupId then cii0.NotChangingTime + cii1.NotChangingTime
when cii0.OldGroupId = cii0.NewGroupId AND cii1.OldGroupId = cii1.NewGroupId AND cii2.OldGroupId IS NULL then cii0.NotChangingTime + cii1.NotChangingTime
when cii0.OldGroupId <> cii0.NewGroupId AND cii1.OldGroupId <> cii1.NewGroupId AND cii2.OldGroupId = cii2.NewGroupId then cii1.NotChangingTime
when cii0.OldGroupId <> cii0.NewGroupId AND cii1.OldGroupId = cii1.NewGroupId AND cii2.OldGroupId = cii2.NewGroupId then NULL
when cii0.OldGroupId <> cii0.NewGroupId AND cii1.OldGroupId = cii1.NewGroupId AND cii2.OldGroupId IS NULL then cii1.NotChangingTime

END RightNotChangingTime
  ,cii1.ServiceRequestId
  --,cii0.rownumber,cii1.RowNumber, cii2.RowNumber,cii0.OldGroupId,cii1.OldGroupId,cii2.OldGroupId
FROM ( --ТЕКУЩАЯ строка
	SELECT -1+row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
	,OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn,NotChangingTime,ServiceRequestId
	FROM @Cii0
) cii1
left join ( --БУДУЩАЯ строка
	SELECT -2+row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
	,OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn,NotChangingTime,ServiceRequestId
	FROM @Cii0
) cii2 ON cii1.RowNumber = cii2.RowNumber AND cii1.ServiceRequestId = cii2.ServiceRequestId
left join ( --ПРОШЛАЯ строка
	SELECT row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
	,OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn,NotChangingTime,ServiceRequestId
	FROM @Cii0
) cii0 ON cii1.RowNumber = cii0.RowNumber AND cii1.ServiceRequestId = cii0.ServiceRequestId


INSERT INTO @GroupTimeCii2 (ServiceRequestId,OldGroupId,MaxNotChangingTime,MinNotChangingTime,SumNotChangingTime)
	SELECT    ServiceRequestId,OldGroupId
			, MAX(RightNotChangingTime)
			, MIN(RightNotChangingTime)
			, SUM(RightNotChangingTime)
	from @CII
	GROUP BY ServiceRequestId, OldGroupID


--Выборка 'Дата перевода на группу'
INSERT INTO @GroupTimeCii0 (ServiceRequestId,OldGroupId,MaxCreatedOn)
	SELECT ServiceRequestId, OldGroupID, MAX(CreatedOn)
	FROM CounterInIncident
	WHERE ServiceRequestId IN ( SELECT id FROM @SR ) AND OldGroupID IS NOT NULL
	GROUP BY ServiceRequestId, OldGroupID

--оставляет MaxChangeDate в тех местах, где OldGroupId не равен NewGroupId
INSERT INTO @GroupTimeCii1 (ServiceRequestId,OldGroupId,MaxCreatedOn)
	SELECT DISTINCT 
		  cii3.ServiceRequestId ServiceRequestId
		, cii3.OldGroupId OldGroupId
		, case
			 when GroupTimeCII0.OldGroupId = cii3.NewGroupId then NULL
			 else GroupTimeCII0.MaxCreatedOn
		END MaxChangeDate
	FROM (
		SELECT ServiceRequestId, OldGroupId, NewGroupId, CreatedOn
		FROM CounterInIncident
		WHERE ServiceRequestId IN ( SELECT id FROM @SR )
		) cii3
	LEFT JOIN @GroupTimeCII0 GroupTimeCII0 ON cii3.ServiceRequestId = GroupTimeCII0.ServiceRequestId 
	      AND cii3.OldGroupID = GroupTimeCII0.OldGroupID
	WHERE cii3.CreatedOn = GroupTimeCII0.MaxCreatedOn --останется только одна строка






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
,GroupTimeCii.MaxNotChangingTime 'Максимальное время обработки группой (мин.)'
,GroupTimeCii.MinNotChangingTime 'Минимальное время обработки группой (мин.)'
,GroupTimeCii.OldGroupID 'Группа'
,GroupTimeCII.MaxCreatedOn 'Дата перевода на группу'
,GroupTimeCii.SumNotChangingTime 'Время обработки группой (мин.)'

FROM @sr sr
LEFT JOIN ServiceRequestType SRT WITH(NOLOCK) ON SRT.Id = SR.ServiceRequestTypeId
LEFT JOIN Service S WITH(NOLOCK) ON S.Id = SR.ServiceId
LEFT JOIN Service Sc WITH(NOLOCK) ON Sc.Id = SR.TechServiceId
LEFT JOIN StatusOfIncident SOI WITH(NOLOCK) ON SOI.Id = SR.StatusOfIncidentId
LEFT JOIN ( --'Общее время обработки (мин.)'
	SELECT ServiceRequestId, SUM(SumNotChangingTime) SumFullNotChangingTime
	FROM @GroupTimeCii2
	GROUP BY ServiceRequestId
	) SumFullCII ON sr.id = SumFullCII.ServiceRequestId

OUTER APPLY (
	SELECT
	  SAU.Name AS OldGroupID
	, MaxNotChangingTime
	, MinNotChangingTime
	, SumNotChangingTime
	, MaxCreatedOn
	FROM
	@GroupTimeCii1 GroupTimeCii1
	LEFT JOIN @GroupTimeCii2 GroupTimeCii2 ON GroupTimeCii2.ServiceRequestId = GroupTimeCii1.ServiceRequestId
											    AND GroupTimeCII1.OldGroupId = GroupTimeCII2.OldGroupId
	LEFT JOIN SysAdminUnit SAU WITH(NOLOCK) ON SAU.Id = GroupTimeCII1.OldGroupId
	WHERE SR.id = GroupTimeCii1.ServiceRequestId
) GroupTimeCII




